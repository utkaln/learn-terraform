provider "kubernetes" {
  load_config_file       = "false"
  host                   = data.aws_eks_cluster.jan22-eks-cluster.endpoint
  token                  = data.aws_eks_cluster_auth.jan22-eks-cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.jan22-eks-cluster.certificate_authority.0.data)
}

data "aws_eks_cluster" "jan22-eks-cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "jan22-eks-cluster" {
  name = module.eks.cluster_id
}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  cluster_name                    = "jan22-eks-cluster"
  cluster_version                 = "1.21"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }
  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]

  enable_irsa = true
  // specify the private subnets as those will house the worker nodes
  // do not specify public subnets as those are for loadbalancers
  subnet_ids = module.eks-vpc.private_subnets
  vpc_id     = module.eks-vpc.vpc_id

  tags = {
    environment = "dev"
    application = "jan22-eks"
  }

  // Node group configuration needed to schedule coredns which is critical for running internal DNS
  eks_managed_node_groups = {
    example = {
      desired_size = 1

      instance_types = ["t2.micro"]
      labels = {
        Example    = "managed_node_groups"
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }
      tags = {
        Name = "coredns_node_group"
        Type = "Terraform"
      }
    }
  }


  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "backend"
          labels = {
            Application = "backend"
          }
        },
        {
          namespace = "default"
          labels = {
            WorkerType = "fargate"
          }
        }
      ]

      tags = {
        Owner = "default"
      }

      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }
  }


}
