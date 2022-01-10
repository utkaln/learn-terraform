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
variable "instance_type" {}
variable "image_name" {}
variable "public_key_location" {}

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

// Create EC2 instance

// First choose AMI for the instance with the filter
data "aws_ami" "utkal-ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = var.image_name
  }

}

output "ami_id" {
  value = data.aws_ami.utkal-ami
}

resource "aws_instance" "utkal-EC2" {
  // Use the ami id that matches the desired description
  ami = data.aws_ami.utkal-ami.id

  // drive instance type as a parameter for flexibility
  instance_type = var.instance_type

  // subnet id should match to the subnet created above in the custom vpc
  subnet_id = aws_subnet.utkal-subnet.id

  // associated the configured SG above
  vpc_security_group_ids = [aws_security_group.utkal_sg.id]

  // associate AZ to be in the same AZ as that of the subnet above
  availability_zone = var.def_az

  // Allow external IP to access the instance
  associate_public_ip_address = true

  // Associate the key pair to be able to allow access to the instance via SSH
  key_name = aws_key_pair.utkal-key-pair.key_name

  tags = {
    Name = "${var.env_prefix}-server-instance"
  }
}

output "ec2_id" {
  value = aws_instance.utkal-EC2
}

resource "aws_key_pair" "utkal-key-pair" {
  // Create a key name through which it can be referred
  key_name = "learn-terraform-key"

  // this is the local public key located in .ssh/id_rsa_pub 
  public_key = file(var.public_key_location)
}
