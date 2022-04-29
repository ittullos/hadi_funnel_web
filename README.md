# hadi_funnel_web

Steps to Re-Deploy (redirect to https enabled)

1 - Delete Cloudfront distribution

    * These steps must be taken in this order. Many AWS operations silently mutate the ETag

    * Disable distribution from the AWS Cloudfront console

    * Wait for distribution to re-deploy

    * Find distribution ETag:

        - aws cloudfront get-distribution --id DistributionID

    * Delete distribution:

        - aws cloudfront delete-distribution --id DistributionID --if-match ETag

2 - Delete HadiFunnel stack:

    - aws cloudformation delete-stack --stack-name HadiFunnel

3 - Build and Re-deploy app:

    - sam build && sam deploy

4 - Update s3 bucket policy (mdl-hadi-funnel)

    * Policy already has a Cloudfront distribution listed here and
      I'm not sure where this comes from. Will append to the existing policy

    * Example policy:

        -
          {
              "Version": "2012-10-17",
              "Id": "PolicyForCloudFrontPrivateContent",
              "Statement": [
                  {
                      "Effect": "Allow",
                      "Principal": {
                          "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity EH1HDMB1FH2TC"
                      },
                      "Action": "s3:GetObject",
                      "Resource": "arn:aws:s3:::DOC-EXAMPLE-BUCKET/*"
                  }
              ]
          }

          * See documentation to find OAI

    * Documentation: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html

    * At this point the s3 bucket is accessible by the cloudfront url
      and the home page displays

5 - Change api endpoint in s3 bucket (index.html line 158) to the new api URL

6 - Change api origin path inside the cloudfront console to /Prod
