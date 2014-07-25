#!/usr/bin/ruby
# Encoding: UTF-8

require 'aws-sdk'
require 'time'
require 'thread'
require 'optparse'

options = Hash.new

parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename __FILE__}"

  opts.on('--prefix PREFIX', 's3 prefix for "directory" containing most recent cloudtrail logs') do |prefix|
    options[:prefix] = prefix
  end
  
  opts.on('--bucket BUCKET', 's3 bucket containing cloudtrail logs') do |bucket|
    options[:bucket] = bucket
  end
    
  opts.on('--aws-key KEY', 'aws key') do |aws_key|
    options[:aws_key] = aws_key
  end
  
  opts.on('--aws-secret SECRET', 'aws secret') do |aws_secret|
    options[:aws_secret] = aws_secret
  end
  
  options[:path] = "#{File.dirname(__FILE__)}"
  opts.on('--path PATH', 'path to copy the cloudtrail logs. defaults to current directory') do |path|
    options[:path] = path
  end
end

parser.parse!

if options[:prefix] == nil || options[:aws_key] == nil || options[:aws_secret] == nil || options[:bucket] == nil
  puts parser.help
  exit 1
end

prefix = options[:prefix]
aws_key = options[:aws_key]
aws_secret = options[:aws_secret]
bucket = options[:bucket]
path = options[:path]

# Log downloads from S3 are multithreaded to speed things along
THREAD_COUNT = 10

s3 = AWS::S3.new(access_key_id: aws_key, secret_access_key: aws_secret)
bucket = s3.buckets[bucket]

objects = []

bucket.objects.with_prefix(prefix).each do |obj|
  objects.push(obj)
end

mutex = Mutex.new

threads = []
for i in (1..THREAD_COUNT) do
  thread = Thread.new do
    while !objects.empty?
      obj = nil
      mutex.synchronize do
        obj = objects.pop
      end
      
      begin
        puts obj.key
        File.open("#{path}/#{obj.key.split("/")[-1]}", 'wb') do |file|
          obj.read do |chunk|
            file.write(chunk)
          end
        end
        %x(gunzip -f #{path}/#{obj.key.split("/")[-1]})
      rescue StandardError => e
        mutex.synchronize do
          puts e.message
          # if an error occurs, push the object back onto the queue and try again
          objects.push(obj)
        end
      end
    end
  end
  threads.push(thread)
end

threads.each do |t|
  t.join
end

puts objects
