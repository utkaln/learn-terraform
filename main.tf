provider "aws" {
  region = "us-east-1"
}


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


// Invoke a module to build subnet
module "utkal_subnet_module" {
  source            = "./modules/subnet"
  vpc_id            = aws_vpc.utkal_vpc.id
  subnet_cidr_block = var.subnet_cidr_block
  def_az            = var.def_az
  rt_outside        = var.rt_outside
  env_prefix        = var.env_prefix

}

module "utkal_ec2_instance" {
  source                = "./modules/webserver"
  ssh_ip                = var.ssh_ip
  vpc_id                = aws_vpc.utkal_vpc.id
  http_ip               = var.http_ip
  env_prefix            = var.env_prefix
  image_name            = var.image_name
  public_key_location   = var.public_key_location
  instance_type         = var.instance_type
  def_az                = var.def_az
  subnet_from_module_id = module.utkal_subnet_module.subnet_from_module.id
}



