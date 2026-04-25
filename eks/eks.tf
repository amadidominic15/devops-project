# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.3"

  cluster_name                   = "${var.project}-eks-${var.environment}"
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true
  cluster_upgrade_policy = {
   support_type = "STANDARD"
  }

  vpc_id     = data.aws_vpc.selected.id
  subnet_ids = data.aws_subnets.private_subnets.ids
  control_plane_subnet_ids = data.aws_subnets.private_subnets.ids

  create_cluster_security_group            = false
  create_node_security_group               = false
  enable_cluster_creator_admin_permissions = true
  enable_irsa                              = true #for ebs csi driver

  cluster_addons = {
    eks-pod-identity-agent = { most_recent = true }
    kube-proxy             = { most_recent = true }
    vpc-cni                = { most_recent = true }
  }
  
  tags = {
    Project     = var.project
    Environment = var.environment
    Terraform   = "true"
  }
}


