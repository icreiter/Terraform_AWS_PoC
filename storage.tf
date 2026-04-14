### S3 Bucket for Data Lake Landing Zone ###

# 1. Create S3 bucket for raw data zone
resource "aws_s3_bucket" "data_lake_raw" {
  # Global unique name for S3 bucket
  # Changing name to avoid resident conflict in localstack
  bucket = "interview-data-lake-raw-zone-14042026-v2"

  ### WORKAROUND: Disabled tags to avoid LocalStack 403 compatibility errors with dummy credentials.
  # tags = {
  #   Name        = "Data-Lake-Raw-Zone"
  #   Environment = "Interview-PoC"
  #   Purpose     = "Data Enginering Landing ZOne"
  # }
}

# 2. Versioning - avoid overwrite raw data during ETL script
resource "aws_s3_bucket_versioning" "data_lake_versioning" {
  bucket = aws_s3_bucket.data_lake_raw.id

  versioning_configuration {
    status = "Enabled"
  }
}

# 3. Block Public Access 
resource "aws_s3_bucket_public_access_block" "data_lake_security" {
  bucket                  = aws_s3_bucket.data_lake_raw.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 4. Server-side encryption (Encrypting static data)
resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake_encryption" {
  bucket = aws_s3_bucket.data_lake_raw.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
