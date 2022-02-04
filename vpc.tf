provider "aws" {
  region = var.region_name
}
variable "vpc_cidr_block" {}
variable "private_subnets" {}
variable "public_subnets" {}
variable "region_name" {}
data "aws_availability_zones" "azs" {

}

module "eks-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.4"
  # insert the 23 required variables here

  name = "jan22-eks-vpc"
  cidr = var.vpc_cidr_block
  // for EKS we need one public and one private subnet in each AZ
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1f"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  // through enabled by default, declaring makes it transparent
  enable_nat_gateway = true
  // enable single gateway for creating all private subnets to route internet traffic
  single_nat_gateway = true

  // provides public DNS
  enable_dns_hostnames = true


  tags = {
    Terraform   = "true"
    Environment = "dev"
    // tag required by cloud controller manager (part of control plane)
    "kubernetes.io/cluster/jan22-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    // tag required by cloud controller manager (part of control plane)
    "kubernetes.io/cluster/jan22-eks-cluster" = "shared"
  }

  private_subnet_tags = {
    // this tag is required by control plane to use clusters for private comm
    // tag required by cloud controller manager (part of control plane)
    "kubernetes.io/cluster/jan22-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb"         = 1

  }
}

resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    environment = "dev"
    application = "jan22-eks"
  }
}
