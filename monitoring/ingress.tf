provider "kubernetes" {
  client_certificate     = "${base64decode(module.monitoring_cluster_gke.cluster_client_certificate)}"
  client_key             = "${base64decode(module.monitoring_cluster_gke.cluster_client_key)}"
  cluster_ca_certificate = "${base64decode(module.monitoring_cluster_gke.cluster_ca)}"
  host                   = "${module.monitoring_cluster_gke.host}"
}

resource "kubernetes_ingress" "kibana-ingress" {
  metadata {
    name      = "kibana"
    namespace = "logging"

    annotations {
      "kubernetes.io/ingress.class" = "traefik"
    }

    labels = {
      createdby = "terraform"

      # datacenter = "${var.cluster_name}"
    }
  }

  spec {
    backend {
      service_name = "kibana"
      service_port = 80
    }

    rule {
      http {
        path {
          path_regex = "/"

          backend {
            service_name = "kibana"
            service_port = 80
          }
        }
      }
    }
  }
}
