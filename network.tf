### 1. Data Sources ###
# Get info for current Region
data "aws_region" "current" {}

# Sourcing the healthy and available AZ from current Region 
data "aws_availability_zones" "available" {
  state = "available"
}

### Network Infrastructure ###
# 1. Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    name = "My-Interview-VPC"
  }
}

# 2. Create IGW to connect internet
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "My-Interview-IGW"
  }
}

# 3. create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"

  # Dynamically getting first AZ from list
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true # automaticaly provide public network IP

  tags = {
    Name = "Public-Subnet-App"
  }

}

# 4. Create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"

  # Keep same AZ with public subnet
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false # never provide public network IP

  tags = {
    Name = "Public-Subnet-DB"
  }

}

# 5. Create public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id # access internet via igw
  }

  tags = {
    Name = "Public-RT"
  }

}

# Associating public subnet and public route table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}


