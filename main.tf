provider "aws" {
  region = "us-east-1"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "def_az" {} //env var set
variable "env_prefix" {}
variable "rt_outside" {}
variable "ssh_ip" {}
variable "http_ip" {}

// Create a custom VPC using credentials from aws cli configure
// Credentials are locally available under ~/.aws/configure
// Tag for Name: dev-vpc
resource "aws_vpc" "utkal_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}
output "vpc_id" {
  value = aws_vpc.utkal_vpc.id
}


// Create subnet and associate with the VPC created above
// Reads CIDR block from the var files
resource "aws_subnet" "utkal-subnet" {
  vpc_id            = aws_vpc.utkal_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.def_az

  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

output "subnet_id" {
  value = aws_subnet.utkal-subnet.id
}

// Create a custom route table to allow https traffic from outside
// RT also allows port 22 access from outside for SSH access
// Declare the ports to be open from outside

resource "aws_route_table" "utkal-rt" {
  vpc_id = aws_vpc.utkal_vpc.id
  route {
    // default for VPC is created implicitly
    // start with Internet Gateway
    cidr_block = var.rt_outside
    gateway_id = aws_internet_gateway.utkal-igw.id
  }
  tags = {
    Name = "${var.env_prefix}-rt-1"
  }
}

output "rt_id" {
  value = aws_route_table.utkal-rt
}

// Internet Gateway is required for Route Table to access to internet
resource "aws_internet_gateway" "utkal-igw" {
  vpc_id = aws_vpc.utkal_vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

output "igw_id" {
  value = aws_internet_gateway.utkal-igw
}

// Associate custom route table with the subnet created above
resource "aws_route_table_association" "utkal-rt-associate" {
  subnet_id      = aws_subnet.utkal-subnet.id
  route_table_id = aws_route_table.utkal-rt.id
}

// Create a security group
resource "aws_security_group" "utkal_sg" {
  name        = "utkal_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.utkal_vpc.id

  // Inbound rule for SSH access to local laptop  
  ingress {
    description = "SSH from Local laptop"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_ip
  }

  // Inbound rule for HTTP access for everyone
  ingress {
    description = "HTTP from everywhere"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.http_ip
  }

  // Outbound rule to not limit any port or any protocol
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}

output "sg_name" {
  value = aws_security_group.utkal_sg.name
}
