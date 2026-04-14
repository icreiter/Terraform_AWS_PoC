
### Localstack cannot find AMI, changing to fix AMI ID
# Search the latest Amazon linux 2 AMI version
# data "aws_ami" "amazon_linux_2" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }
# }

# SSH Key Pair
# 1. Dynamically generate a RSA private key via Terraform
resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. Register the public key to AWS as key Pair
resource "aws_key_pair" "bastion_key_pair" {
  key_name   = "TPE-Bastion-Key"
  public_key = tls_private_key.bastion_key.public_key_openssh
}

# 3. Create EC2 bastion into public subnet
resource "aws_instance" "bastion_host" {
  # ami           = data.aws_ami.amazon_linux_2.id 
  ### Let localstack can get the ami ###
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet.id

  key_name = aws_key_pair.bastion_key_pair.key_name

  # Associating with security group
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "Bastion-Host"
  }

}

# Subnet group for RDS
resource "aws_db_subnet_group" "rds_group" {
  name       = "main_db_group"
  subnet_ids = [aws_subnet.private_subnet.id]

  tags = {
    Name = "My-DB-Subnet-Group"
  }
}

# Establish MySQL Database in private subnet
resource "aws_db_instance" "mysql_db" {
  allocated_storage = 20
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  db_name           = "interview_db"
  username          = "admin"

  # Get the password from Secrets Manager
  password = aws_secretsmanager_secret_version.db_password_val.secret_string

  db_subnet_group_name   = aws_db_subnet_group.rds_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  skip_final_snapshot = true

  tags = {
    Name = "Private-MySQL-DB"
  }
}
