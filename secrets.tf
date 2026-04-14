# Automatically random password generate
# resource "random_password" hashicorp's general function
resource "random_password" "db_master_password" {
  length  = 16
  special = true

  # Avoiding Connection String/URI using special charactor when connecting
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Create Secrets Manager
resource "aws_secretsmanager_secret" "db_master_password" {
  name                    = "rds-db-password-TPE"
  description             = "Main database password for RDS mySQL"
  recovery_window_in_days = 0 # only for Localstack simulation env.

  tags = {
    Environment = "Interview-PoC"
  }
}

# Saving the random password into Secrets Manager
resource "aws_secretsmanager_secret_version" "db_password_val" {
  secret_id     = aws_secretsmanager_secret.db_master_password.id
  secret_string = random_password.db_master_password.result
}
