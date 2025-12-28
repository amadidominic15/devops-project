module "eks_blueprint_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.21.1"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_ingress_nginx         = false
  enable_aws_load_balancer_controller    = true
  enable_kube_prometheus_stack = true
  enable_argocd                = true

  aws_load_balancer_controller {
    chart      = "aws-load-balancer-controller"
    repository = "https://aws.github.io/eks-charts"
    namespace  = "kube-system"
  }

  kube_prometheus_stack = {
    chart         = "kube-prometheus-stack"
    chart_version = "77.0.0"
    repository    = "https://prometheus-community.github.io/helm-charts"
    namespace     = "monitoring"
  }

  argocd = {
    chart         = "argo-cd"
    chart_version = "8.6.3"
    repository    = "https://argoproj.github.io/argo-helm"
    namespace     = "argocd"
    values = [
      yamlencode({
        server = {
          config = {
            url = "https://argocd.online-boutique.com"
          }
        }
      })
    ]
  }
}

resource "helm_release" "gateway_api" {
  name       = "gateway-api"
  repository = "https://kubernetes-sigs.github.io/gateway-api"
  chart      = "gateway-api"
  namespace  = "gateway-system"
  version    = "1.2.0"

  create_namespace = true
}



# Install the AWS Load Balancer Controller via Helm
resource "helm_release" "aws_load_balancer_controller" {
  depends_on = [module.eks_managed_node_group]
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "region"
    value = "us-east-1"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.eks-alb-ingress-controller.name}"
  }
}


resource "helm_release" "prometheus" {
  create_namespace = true
  name       = "prometheus"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
 // version    = "15.2.1" # Ensure this matches the version you want
  values = [templatefile("${var.environment}/values_prom.yaml", {
    DESTINATION_GMAIL_ID   = var.DESTINATION_GMAIL_ID
    SOURCE_AUTH_PASSWORD   = var.SOURCE_AUTH_PASSWORD
    SOURCE_GMAIL_ID        = var.SOURCE_GMAIL_ID
  })]
}


resource "helm_release" "grafana" {
  create_namespace = true
  name       = "grafana"
  namespace  = "monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
 // version    = "15.2.1" # Ensure this matches the version you want
  values = [
    file("${var.environment}/values_grafana.yaml") # Path to your custom values file
  ]
  set {
    name  = "adminPassword"
    value = "admin"
  }
}



