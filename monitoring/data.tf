data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["${var.project}-${var.environment}"]
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private_subnets.ids)
  id = each.value
}

data "kubernetes_resource" "gateway" {
  api_version = "gateway.networking.k8s.io/v1"
  kind        = "Gateway"

  metadata {
    name      = "main-gateway"
    namespace = "kube-system"
  }
}

data "aws_route53_zone" "zone" {
  name = var.domain_name 
}

locals {
  gateway_endpoint = data.kubernetes_resource.gateway.object.status.addresses[0].value
}