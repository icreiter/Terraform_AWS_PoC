# create security group for EC2 bastion
resource "aws_security_group" "ec2_sg" {
  name   = "EC2-Bastion-SG"
  vpc_id = aws_vpc.main_vpc.id

  # allow SSH in
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow all request to public internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create security group for Relational Databaes
resource "aws_security_group" "rds_sg" {
  name   = "RDS-Private-SG"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    # only allow entry from bastion security group
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



