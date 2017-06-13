require 'aws-sdk'
require 'pp'

sts = Aws::STS::Client.new
pp sts.get_caller_identity
