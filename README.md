cloudtrail-analyzer
===================

A very simple pair of ruby scripts for fetching cloud trail logs from S3 and finding what a specific API key has been up to. I wrote this originally because I had to rotate a key that was used for various purposes across hundreds of hosts, and I needed to ensure no hosts were still using the key, and if they were, what they were doing.

get-cloudtrail-logs.rb retrieves a set of cloudtrail logs from a specified bucket and prefix, and analyze-cloudtrail.rb reads each file and builds up some some stats about the specified search key.

# Usage

$ mkdir ./logs
$ ./get-cloudtrail-logs.rb --prefix AWSLogs/<YOUR ACCOUNT NUMBER>/CloudTrail/us-east-1/2014/07/25 --aws-key <YOUR_AWS_KEY> --aws-secret <YOUR_SECRET_KEY> --path ./logs --bucket <YOUR_CLOUDTRAIL_BUCKET>
$ ./analyze-cloudtrail.rb --key <SEARCH_API_KEY> --path ./logs

# Output

API Event,Count,Last Time Seen,Last Source IP Address
DeleteSnapshot, 951, 2014-07-24T00:04:26+00:00, 169.x.x.x
DescribeSnapshots, 219090, 2014-07-24T19:21:53+00:00, 169.x.x.x
DescribeInstanceStatus, 9622, 2014-07-24T19:20:02+00:00, 169.x.x.x
DescribeInstances, 13718, 2014-07-24T23:45:02+00:00, 169.x.x.x
DescribeVolumes, 1166, 2014-07-24T22:00:07+00:00, 169.x.x.x
DescribeSecurityGroups, 1529, 2014-07-24T19:19:20+00:00, 169.x.x.x
CreateSnapshot, 966, 2014-07-24T22:00:07+00:00, 169.x.x.x
DescribeTags, 979, 2014-07-24T19:10:25+00:00, 169.x.x.x
AssociateAddress, 7, 2014-07-24T23:00:50+00:00, 169.x.x.x
DescribeAddresses, 30, 2014-07-24T23:18:40+00:00, 169.x.x.x
CreateTags, 9, 2014-07-24T23:19:11+00:00, 5169.x.x.x
DescribeAutoScalingGroups, 1, 2014-07-24T16:07:38+00:00, 169.x.x.x
DescribeImages, 10, 2014-07-24T23:19:11+00:00, 169.x.x.x
RunInstances, 4, 2014-07-24T23:18:45+00:00, 169.x.x.x

