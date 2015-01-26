#!/usr/bin/env ruby

require 'aws-sdk-core'
require 'slop'

REGION = "us-east-1"
INDEX = "index.html"
ERROR = "error.html"

class S3tatic

  def initialize(domain: nil, region: REGION, index: INDEX, error: ERROR)
    @domain = domain
    @region = region
    @index = index
    @error = error
  end

  def domain
    @domain
  end

  def region
    @region
  end

  def s3_endpoint
    @s3_endpoint = "#{@domain}.s3-website-#{region}.amazonaws.com"
  end

  def policy
    policy = '{
      "Version":"2012-10-17",
      "Statement":[{
        "Sid":"AddPerm",
        "Effect":"Allow",
        "Principal": "*",
        "Action":["s3:GetObject"],
        "Resource":["arn:aws:s3:::' + @domain + '/*"]
      }]
    }'
    return policy
  end

  def create_bucket
    @s3 = Aws::S3::Client.new(region: @region)
    begin
      @s3.create_bucket(
        bucket: @domain,
        acl: 'public-read'
      )
    rescue Exception => e
      puts "Error: #{e.message}"
      abort
    end
  end

  def define_policy
    begin
      @s3.put_bucket_policy(
        bucket: @domain,
        policy: self.policy
      )
    rescue Exception => e
      puts "Error: #{e.message}"
      abort
    end
  end

  def configure_website
    begin
      @s3.put_bucket_website(
        bucket: @domain,
        website_configuration: {
          index_document: {
            suffix: @index
          },
          error_document: {
            key: @error
          }
        }
      )
    rescue Exception => e
      puts "Error: #{e.message}"
      abort
    end
  end

end

if __FILE__ == $0

  opts = Slop.parse do
    banner 'Usage: s3tatic.rb --domain <domain>'
    on 'domain=', 'myweb.mydomain.com'
    on 'region=', 'aws region', :default => REGION
    on 'index=', 'index page', :default => INDEX
    on 'error=', 'error page', :default => ERROR
  end

  if not opts[:domain]
    puts opts.help
    abort
  end

  s = S3tatic.new(
    domain: opts[:domain],
    region: opts[:region],
    index: opts[:index],
    error: opts[:error],
  )

  puts " >> Creating S3 bucket #{s.domain} on #{s.region}"
  s.create_bucket

  puts ' >> Defining bucket policy'
  s.define_policy

  puts ' >> Configuring website attributes'
  s.configure_website

  puts " >> Done. What's next?\n" +
       "(1) Manually create the CNAME registry #{s.domain}\n" +
       "    pointing to #{s.s3_endpoint}\n" +
       "(2) Put files in the bucket and visit http://#{s.domain}"

end

