# Enable cloudtrail for entire organization.
resource "aws_cloudtrail" "main" {
  provider                      = aws.${provider}
  name                          = "${bucket}"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_organization_trail         = true
}

# Create bucket for holding cloudtrail events for the entire organization.
resource "aws_s3_bucket" "cloudtrail" {
  provider = aws.${provider}
  bucket   = "${bucket}"
  policy   = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailAclCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${bucket}"
    },
    {
      "Sid": "AWSCloudTrailWrite",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${bucket}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    }
  ]
}
POLICY
}

# Ensure the state bucket never becomes public.
resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  provider                = aws.${provider}
  bucket                  = aws_s3_bucket.cloudtrail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}