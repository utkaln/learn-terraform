provider "aws" {
  region = "us-east-2"
}

module "mahanadi-eks-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.3"
  # insert the 23 required variables here

  name = "mahanadi-eks-vpc"
  cidr = "10.0.0.0/16"
  // for EKS we need one public and one private subnet in each AZ
  azs             = data.aws_availability_zones.azs.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    Terraform                                    = "true"
    Environment                                  = "dev"
    "kubernetes.io/cluster/mahanadi-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb"                     = 1
    "kubernetes.io/cluster/mahanadi-eks-cluster" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"            = 1
    "kubernetes.io/cluster/mahanadi-eks-cluster" = "shared"
  }
}

data "aws_availability_zones" "azs" {}
