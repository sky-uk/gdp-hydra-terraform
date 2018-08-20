resource "kubernetes_ingress" "prometheus-ingress" {
  metadata {
    name = "prometheus-ingress"
    namespace = "monitoring"
    annotations {
      "kubernetes.io/ingress.class"          = "traefik"
      "ingress.kubernetes.io/rewrite-target" = "/federate"
      "traefik.ingress.kubernetes.io/rule-type" = "PathPrefixStrip"
    }
  }

  spec {
    backend {
      service_name = "prometheus-slaves"
      service_port = 9090
    }

    rule {
      http {
        path {
          path_regex = "/federate"

          backend {
            service_name = "prometheus-slaves"
            service_port = 9090
          }
        }
      }
    }
  }
}
