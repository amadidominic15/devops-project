resource "helm_release" "kube_prometheus_stack" {
  name       = "kps"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "77.0.0"

  create_namespace = true

  values = [yamlencode({
    grafana = {
      service = { type = "ClusterIP" }
    }

    prometheus = {
      service = { type = "ClusterIP" }
    }

    alertmanager = {
      service = { type = "ClusterIP" }
    }
  })]
}

resource "helm_release" "loki" {
  name       = "loki"
  namespace  = "monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "5.47.2"

  values = [yamlencode({
    service = {
      type = "ClusterIP"
    }
  })]
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "8.6.3"

  create_namespace = true

  values = [yamlencode({
    server = {
      service = {
        type = "ClusterIP"
      }
    }
  })]
}

resource "helm_release" "gateway_api" {
  name       = "gateway-api"
  namespace  = "gateway-system"
  repository = "https://kubernetes-sigs.github.io/gateway-api"
  chart      = "gateway-api"
  version    = "1.2.0"

  create_namespace = true
}