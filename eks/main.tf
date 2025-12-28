# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.3"

  cluster_name                   = "${var.project}-eks-${var.environment}"
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  create_cluster_security_group            = false
  create_node_security_group               = false
  enable_cluster_creator_admin_permissions = true
  enable_irsa                              = true # for ebs csi driver

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
    most_recent = true
    }
  }
  eks_managed_node_groups = {
    eks_node = {
      instance_types = ["${var.instance_type}"]
      min_size       = 2
      max_size       = 4
      desired_size   = 2
    }
  }
  tags = local.tags
}

