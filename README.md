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

    * See documentation to find example policy and OAI

    * Documentation: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html

    * At this point the s3 bucket is accessible by the cloudfront url
      and the home page displays

5 - Set up the custom domain name for the cloudfront distribution

    * Go into the cloudfront console and select the distribution

    * Click the edit button next to the settings panel

    * type "myhadi.com" in the alternate domain name section

    * Click the certificte drop-down and select myhadi.com

    * Go into the Route 53 console

    * Click on hosted zones and then click on myhadi.com

    * Delete the A record that is here currently

    * Create a new record of type A

    * Click the alias button and select the correct distribution from the drop down menu

6 - Change api endpoint in s3 bucket (index.html line 158) to the new api URL

    * Go into the API gateway console

    * Select the HadiFunnel API

    * Click on stages in the left panel

    * Click the Prod dropdown and select the GET method for the "new_customer" path

    * Copy the invoke url

    * Paste it on line 158 of index.html in place of the existing url

7 - Change url for css file and icon

    * Copy the distribution url from the cloudfront console

    * Open layout.erb

    * Paste the cloudfront url in place of the base url on line 11 and 13 (keep the url path the same)

8 - Change the url for the form submission

    * Copy the API gateway invoke url again (See step 6)

    * Paste it on line 10 of email_form.erb

Everything should be deployed and working
