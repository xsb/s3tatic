S3tatic
=======

Creates and configures Amazon S3 buckets to use as a static web hosting.

S3tatic expects the environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to be able to use the Amazon Web Services API.

To put files in the S3 bucket after creating it, use some other tool like [s3cmd](http://s3tools.org/s3cmd-sync).

```sh
$ s3tatic.rb
Usage: s3tatic.rb --domain <domain>
        --domain      myweb.mydomain.com
        --region      aws region (default: us-east-1)
        --index       index page (default: index.html)
        --error       error page (default: error.html)
```

```sh
$ s3tatic.rb --domain myweb.mydomain.com
>> Creating S3 bucket myweb.mydomain.com on us-east-1
>> Defining bucket policy
>> Configuring website attributes
>> Done. What's next?
(1) Manually create the CNAME registry myweb.mydomain.com
    pointing to myweb.mydomain.com.s3-website-us-east-1.amazonaws.com
(2) Put files in the bucket and visit http://myweb.mydomain.com
```
