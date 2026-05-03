# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.3"

  cluster_name                   = "${var.project}-${var.environment}-eks"
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true
  cluster_upgrade_policy = {
   support_type = "STANDARD"
  }

  vpc_id     = data.aws_vpc.selected.id
  subnet_ids = data.aws_subnets.private_subnets.ids
  control_plane_subnet_ids = data.aws_subnets.private_subnets.ids

  create_cluster_security_group            = true
  create_node_security_group               = true
  enable_cluster_creator_admin_permissions = true
  enable_irsa                              = true # oidc for ebs, api controller, etc

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


