module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.2.3"
  cluster_name    = "jan22-eks-cluster"
  cluster_version = "1.21"

  // specify the private subnets as those will house the worker nodes
  // do not specify public subnets as those are for loadbalancers
  subnet_ids = module.eks-vpc.private_subnets
  vpc_id     = module.eks-vpc.vpc_id

  tags = {
    environment = "dev"
    application = "jan22-eks"
  }

  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "kube-system"
          labels = {
            k8s-app = "kube-dns"
          }
        },
        {
          namespace = "default"
        }
      ]

      tags = {
        Owner = "test"
      }

      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }
  }


}
