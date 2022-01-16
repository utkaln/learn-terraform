provider "kubernetes" {
  load_config_file       = "false"
  host                   = module.mahanadi-eks-cluster.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.mahanadi-cluster.token
  cluster_ca_certificate = base64decode(module.mahanadi-eks-cluster.certificate_authority_data)
}

data "aws_eks_cluster_auth" "mahanadi-cluster" {
  name = "mahanadi-eks-cluster"
}

module "mahanadi-eks-cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.2.0"

  cluster_name    = "mahanadi-eks-cluster"
  cluster_version = "1.23"

  subnet_ids = module.mahanadi-eks-vpc.private_subnets
  vpc_id     = module.mahanadi-eks-vpc.vpc_id


  // optional tags
  tags = {
    Environment = "dev"
    application = "mahanadi-eks-app"
  }
  

}
