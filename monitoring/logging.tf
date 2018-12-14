provider "helm" {
  version = "~> 0.6"

  kubernetes {
    client_certificate     = "${base64decode(module.monitoring_cluster.cluster_client_certificate)}"
    client_key             = "${base64decode(module.monitoring_cluster.cluster_client_key)}"
    cluster_ca_certificate = "${base64decode(module.monitoring_cluster.cluster_ca)}"
    host                   = "${module.monitoring_cluster.host}"
  }
}

locals {
  elasticsearch_host = "elascticsearch-elasticsearch-coordinating-only"
}

resource "helm_release" "fluentd" {
  name      = "fluentd"
  chart     = "stable/fluentd-elasticsearch"
  namespace = "logging"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  set {
    name  = "rbac.create"
    value = "false"
  }

  set {
    name  = "elasticsearch.host"
    value = "${local.elasticsearch_host}"
  }
}

resource "helm_release" "elasticsearch" {
  name       = "elascticsearch"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "elasticsearch"
  namespace  = "logging"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  set {
    name  = "rbac.create"
    value = "false"
  }
}

data "template_file" "fluentd_ingress_values" {
  template = "${file("${path.module}/values/fluentd-ingress.values.yaml")}"

  vars {
    elasticsearch_host = "${local.elasticsearch_host}"
  }
}

resource "helm_release" "fluentd_ingest" {
  name      = "fluentd-ingest"
  chart     = "incubator/fluentd"
  namespace = "logging"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${data.template_file.fluentd_ingress_values.rendered}",
  ]

  # depends_on = [
  #   "helm_release.traefik",
  # ]
}

# resource "kubernetes_ingress" "fluentd-ingress" {
#   metadata {
#     name      = "fluentd"
#     namespace = "logging"

#     annotations {
#       "kubernetes.io/ingress.class"             = "traefik"
#     }

#     labels = {
#       createdby = "terraform"
#     }
#   }

#   spec {
#     rule {
#       host = "${var.monitoring_dns_name}"

#       http {
#         path {
#           path_regex = "/"

#           backend {
#             protocol = "TCP"
#             service_name = "http-input"
#             service_port = 9880
#           }
#         }
#       }
#     }
#   }
# }
