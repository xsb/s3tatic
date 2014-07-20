#!/usr/bin/env ruby

require 'aws-sdk-core'
require 'slop'

class WebBucket
  def initialize
    opts = Slop.parse do
      banner 'Usage: ssstatic.rb --domain <domain>'
      on 'domain=', 'myweb.mydomain.com'
      on 'region=', 'aws region', :default => 'us-east-1'
      on 'index=', 'index page', :default => 'index.html'
      on 'error=', 'error page', :default => 'error.html'
    end
    if not opts[:domain]
      self.exit(opts.help)
    end
    @domain = opts[:domain]
    @region = opts[:region]
    @index = opts[:index]
    @error = opts[:error]
  end
  def domain
    @domain
  end
  def region
    @region
  end
  def s3_endpoint
    @s3_endpoint = @domain + '.s3-website-' + @region + '.amazonaws.com'
  end
  def policy
    policy = '{
      "Version":"2012-10-17",
      "Statement":[{
        "Sid":"PublicReadGetObject",
        "Effect":"Allow",
        "Principal": {"AWS": "*"},
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
      puts 'Error: ' + e.message
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
      puts 'Error: ' + e.message
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
      puts 'Error: ' + e.message
      abort
    end
  end
  def exit(help)
    puts help
    abort
  end
end

b = WebBucket.new

puts '>> Creating S3 bucket ' + b.domain + ' on ' + b.region
b.create_bucket

puts '>> Defining bucket policy'
b.define_policy

puts '>> Configuring website attributes'
b.configure_website

puts ">> Done. What's next?"
puts '(1) Manually create the CNAME registry ' + b.domain +
  "\n    pointing to " + b.s3_endpoint
puts '(2) Put files in the bucket and visit http://' + b.domain

