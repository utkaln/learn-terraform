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

  self_managed_node_group_defaults = {
    instance_type                          = "t2.micro"
    update_launch_template_default_version = true
    iam_role_additional_policies           = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  }

  self_managed_node_groups = {
    one = {
      name = "spot-1"

      public_ip    = true
      max_size     = 5
      desired_size = 2

    }
  }

}
