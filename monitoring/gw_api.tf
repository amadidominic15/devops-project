resource "kubernetes_manifest" "main_gateway" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = "main-gateway"
      namespace = "default"

      annotations = {
        "alb.networking.k8s.io/scheme"          = "internet-facing"
        "alb.networking.k8s.io/target-type"     = "ip"
        "alb.networking.k8s.io/listen-ports"    = "[{\"HTTPS\":443}]"
        "alb.networking.k8s.io/certificate-arn" = var.acm_certificate_arn

        # 🔐 Strong TLS policy
        "alb.networking.k8s.io/ssl-policy" = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      }
    }
    spec = {
      gatewayClassName = "aws"

      listeners = [
        {
          name     = "https"
          protocol = "HTTPS"
          port     = 443
          hostname = "*.domain.com"

          tls = {
            mode = "Terminate"
          }

          allowedRoutes = {
            namespaces = {
              from = "All"
            }
          }
        }
      ]
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
          name      = "main-gateway"
          namespace = "default"
        }]
      hostnames = ["grafana.${var.domain_name}"]
      rules = [{
          matches = [{
              path = {
                type  = "PathPrefix"
                value = "/"
              }
            }]
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
          name      = "main-gateway"
          namespace = "default"
        }]
      hostnames = ["prometheus.${var.domain_name}"]
      rules = [{
          matches = [{
              path = {
                type  = "PathPrefix"
                value = "/"
              }
            }]

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
          name      = "main-gateway"
          namespace = "kube-system"
        }]
      hostnames = ["argocd.${var.domain_name}"]
      rules = [{
          matches = [{
              path = {
                type  = "PathPrefix"
                value = "/"
              }
            }]

          backendRefs = [{
              name = "argocd-server"
              port = 80
            }]
        }]
    }
  }
}

