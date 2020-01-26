# Bucket to store all tfstate files for this account.
resource "aws_s3_bucket" "terraform_state" {
  provider = aws.${name}
  bucket   = "${name}-tfstate"
  acl      = "private"
  versioning {
    enabled = true
  }
}

# Ensure the state bucket never becomes public.
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  provider                = aws.${name}
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}