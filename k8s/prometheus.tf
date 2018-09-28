resource "kubernetes_namespace" "monitoring" {
  metadata {
    labels = {
      createdby  = "terraform"
      datacenter = "${var.cluster_name}"
    }

    name = "monitoring"
  }
}

resource "kubernetes_ingress" "prometheus-ingress" {
  metadata {
    name      = "prometheus-ingress"
    namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"

    annotations {
      "kubernetes.io/ingress.class"             = "traefik"
      "ingress.kubernetes.io/rewrite-target"    = "/metrics"
      "traefik.ingress.kubernetes.io/rule-type" = "PathPrefixStrip"
    }

    labels = {
      createdby  = "terraform"
      datacenter = "${var.cluster_name}"
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
