#!/usr/bin/ruby

require 'json'
require 'optparse'
require 'date'

options = Hash.new

parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename __FILE__}"

  opts.on('--key KEY', 'aws key') do |key|
    options[:key] = key
  end
  
  options[:path] = "#{File.dirname(__FILE__)}"
  opts.on('--path PATH', 'path to cloudtrail logs. defaults to current directory') do |path|
    options[:path] = path
  end
end

parser.parse!

if options[:key] == nil
  puts parser.help
  exit 1
end

key = options[:key]
path = options[:path]

stats = Hash.new do |h,k|
  h[k] = {
    count: 0,
    last_timestamp: DateTime.new(0)
  }
end

last_time = DateTime.new(0)

Dir.foreach(path) do |file|
  unless file.match(/.+\.json/)
    next
  end
  
  f = File.open("#{path}/#{file}", 'r')
  jsonString = f.read
  f.close
  
  json = JSON.parse(jsonString)
  json["Records"].each do |record|
    unless record['userIdentity']['accessKeyId'] == key
      next
    end
    
    event_name = record['eventName']
    stats[event_name][:count] += 1
    if stats[event_name][:last_timestamp] < DateTime.parse(record['eventTime'])
      stats[event_name][:last_timestamp] = DateTime.parse(record['eventTime'])
    end
    stats[event_name][:ip_address] = record['sourceIPAddress']
  end
end

stats.each do |event,values|
  puts "#{event}, #{values[:count]}, #{values[:last_timestamp]}, #{values[:ip_address]}"
end
