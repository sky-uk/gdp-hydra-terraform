provider "kubernetes" {
  client_certificate     = "${base64decode(module.monitoring_cluster.cluster_client_certificate)}"
  client_key             = "${base64decode(module.monitoring_cluster.cluster_client_key)}"
  cluster_ca_certificate = "${base64decode(module.monitoring_cluster.cluster_ca)}"
  host                   = "${module.monitoring_cluster.host}"
}

# resource "kubernetes_ingress" "kibana-ingress" {
#   metadata {
#     name      = "kibana"
#     namespace = "logging"

#     annotations {
#       "kubernetes.io/ingress.class" = "traefik"
#     }

#     labels = {
#       createdby = "terraform"
#     }
#   }

#   spec {
#     backend {
#       service_name = "kibana"
#       service_port = 80
#     }

#     rule {
#       http {
#         path {
#           path_regex = "/"

#           backend {
#             service_name = "kibana"
#             service_port = 80
#           }
#         }
#       }
#     }
#   }
# }

resource "kubernetes_ingress" "prometheus-ingress" {
  metadata {
    name      = "prometheus"
    namespace = "monitoring"

   annotations {
      "kubernetes.io/ingress.class"             = "traefik"
    }

    labels = {
      createdby = "terraform"
    }
  }

  spec {
    backend {
      service_name = "prometheus-master"
      service_port = 9090
    }

    rule {
      http {
        path {
          path_regex = "/prometheus"

          backend {
            service_name = "prometheus-master"
            service_port = 9090
          }
        }
      }
    }
  }
}
