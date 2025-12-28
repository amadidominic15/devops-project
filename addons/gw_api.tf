resource "kubernetes_manifest" "gateway_api" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = "gateway_api"
      namespace = "kube-system"
      annotations = {
        "alb.networking.k8s.io/scheme"          = "internet-facing"
        "alb.networking.k8s.io/certificate-arn" = var.acm_certificate_arn
        "alb.networking.k8s.io/listen-ports"    = "[{\"HTTPS\":443}]"
      }
    }
    spec = {
      gatewayClassName = "alb"
      listeners = [{
        name     = "https"
        protocol = "HTTPS"
        port     = 443
        hostname = "*.${var.domain_name}"
      }]
    }
  }
}


resource "kubernetes_manifest" "grafana_route" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "grafana-route"
      namespace = "monitoring"
    }
    spec = {
      parentRefs = [{
        name      = "gateway_api"
        namespace = "kube-system"
      }]
      hostnames = ["grafana.${var.domain_name}"]
      rules = [{
        backendRefs = [{
          name = "kube-prometheus-stack-grafana"
          port = 80
        }]
      }]
    }
  }
}

resource "kubernetes_manifest" "prometheus_route" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "prometheus-route"
      namespace = "monitoring"
    }
    spec = {
      parentRefs = [{
        name      = "gateway_api"
        namespace = "kube-system"
      }]
      hostnames = ["prometheus.${var.domain_name}"]
      rules = [{
        backendRefs = [{
          name = "kube-prometheus-stack-prometheus"
          port = 9090
        }]
      }]
    }
  }
}

resource "kubernetes_manifest" "argocd_route" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "argocd-route"
      namespace = "argocd"
    }
    spec = {
      parentRefs = [{
        name      = "gateway_api"
        namespace = "kube-system"
      }]
      hostnames = ["argocd.${var.domain_name}"]
      rules = [{
        backendRefs = [{
          name = "argocd-server"
          port = 80
        }]
      }]
    }
  }
}
