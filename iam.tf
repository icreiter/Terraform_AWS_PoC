
### 1. Create group & permission of DBA ###
resource "aws_iam_group" "dba_group" {
  name = "DBA-Administrators"
}

# Fully permission to DBA
resource "aws_iam_group_policy_attachment" "dba_rds_full" {
  group = aws_iam_group.dba_group.name

  #RDS fully access
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

### 2. Create group & permission of DE for Data lake(S3), ETL(AWS Glue), read RDS ###
resource "aws_iam_group" "de_group" {
  name = "Data-Engineers"
}

resource "aws_iam_group_policy_attachment" "de_s3_full" {
  group = aws_iam_group.de_group.name

  # S3 fully access to build Data Lake
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_group_policy_attachment" "de_glue_full" {
  group = aws_iam_group.de_group.name

  # AWS Glue fully access for future ETL
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}

resource "aws_iam_group_policy_attachment" "de_rds_read" {
  group = aws_iam_group.de_group.name

  # DE can only read data from RDS, cannot remove or edit RDS
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess"
}


### 3. Create group & permission for DA for only read table ###
resource "aws_iam_group" "analyst_group" {
  name = "Data-Analysts"
}

resource "aws_iam_group_policy_attachment" "analyst_rds_read" {
  group      = aws_iam_group.analyst_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "analyst_s3_read" {
  group = aws_iam_group.analyst_group.name

  # DA can only read Data Lake
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


### 4. Create IAM roles and distrube in corresponding group ###
resource "aws_iam_user" "dba_user" {
  name = "john-dba"
}

resource "aws_iam_user_group_membership" "dba_membership" {
  user   = aws_iam_user.dba_user.name
  groups = [aws_iam_group.dba_group.name]
}

resource "aws_iam_user" "de_user" {
  name = "wick-de"
}

resource "aws_iam_user_group_membership" "de_membership" {
  user   = aws_iam_user.de_user.name
  groups = [aws_iam_group.de_group.name]
}

resource "aws_iam_user" "da_user" {
  name = "alice-da"
}

resource "aws_iam_user_group_membership" "da_membership" {
  user   = aws_iam_user.da_user.name
  groups = [aws_iam_group.analyst_group.name]
}

