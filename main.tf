provider "aws" {
  region = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "vpc cidr block"
  default     = "10.0.0.0/24"
  type        = string
}

variable "subnet_1_cidr_block" {
  description = "subnet_1 cidr block"
}

variable "subnet_2_cidr_block" {
  description = "subnet_2 cidr block"
}

variable "def_az" {} //env var set

resource "aws_vpc" "utkal_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "learn-terraform-vpc"
  }
}
output "vpc_id" {
  value = aws_vpc.utkal_vpc.id
}


resource "aws_subnet" "utkal-subnet-1" {
  vpc_id     = aws_vpc.utkal_vpc.id
  cidr_block = var.subnet_1_cidr_block

  tags = {
    Name = "learn-terraform-subnet-1"
  }
}

output "subnet_1_az" {
  value = aws_subnet.utkal-subnet-1.availability_zone
}

data "aws_vpc" "aws_vpc_data" {
  default = true
}

resource "aws_subnet" "utkal-subnet-2" {
  vpc_id            = data.aws_vpc.aws_vpc_data.id
  cidr_block        = var.subnet_2_cidr_block
  availability_zone = var.def_az
  tags = {
    Name = "learn-terraform-subnet-2"
  }
}

output "subnet_2_az" {
  value = aws_subnet.utkal-subnet-2.availability_zone
}
