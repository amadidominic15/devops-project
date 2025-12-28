data "aws_availability_zones" "available" {}

locals {
  name        = "online-boutique"
  k8s_version = "1.33"
  vpc_cidr    = "12.0.0.0/16"
  azs         = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = {
    devops-project = local.name
    GithubRepo      = "devops-project"
  }
}

