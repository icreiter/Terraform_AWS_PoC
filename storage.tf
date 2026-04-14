### S3 Bucket for Data Lake Landing Zone ###

# 1. Create S3 bucket for raw data zone
resource "aws_s3_bucket" "data_lake_raw" {
  # Global unique name for S3 bucket
  bucket = "interview-data-lake-raw-zone-14042026"

  tags = {
    Name        = "Data-Lake-Raw-Zone"
    Environment = "Interview-PoC"
    Purpose     = "Data Enginering Landing ZOne"
  }
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

