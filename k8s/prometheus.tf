resource "kubernetes_secret" "prometheus_metrics_password" {
  metadata {
    name      = "prometheus-metrics"
    namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"

    labels = {
      createdby  = "terraform"
      datacenter = "${var.cluster_name}"
    }
  }

  data {
    auth = "${var.prom_metrics_credentials["username"]}:${bcrypt(var.prom_metrics_credentials["password"])}"
  }

  type = "Opaque"

  # this will stop the password updating on each apply but will also name it difficult to change the password if needed
  # it will probably be required to delete the secret manually and then re-run terraform apply
  lifecycle {
    ignore_changes = ["data.auth"]
  }
}

resource "kubernetes_ingress" "prometheus-ingress" {
  metadata {
    name      = "prometheus-ingress"
    namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"

    annotations {
      "kubernetes.io/ingress.class"               = "traefik"
      "traefik.ingress.kubernetes.io/auth-type"   = "basic"
      "traefik.ingress.kubernetes.io/auth-secret" = "prometheus-metrics"
    }

    labels = {
      createdby  = "terraform"
      datacenter = "${var.cluster_name}"
    }
  }

  spec {
    rule {
      http {
        path {
          path_regex = "/federate"

          backend {
            service_name = "prometheus-prometheus-oper-prometheus"
            service_port = 9090
          }
        }
      }
    }
  }
}
