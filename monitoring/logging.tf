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

# resource "helm_release" "elasticsearch" {
#   name       = "elascticsearch"
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "elasticsearch"
#   namespace  = "logging"

#   # workaround to stop CI from complaining about keyring change
#   keyring = ""

#   set {
#     name  = "rbac.create"
#     value = "false"
#   }
# }

data "template_file" "fluentbit_values" {
  template = "${file("${path.module}/values/fluent-bit.values.yaml")}"
}

# fluent-bit installed as a deamonset to colelct logs from the cluster and send them to the 
# fluentd instance that will push them to elasticsearch
resource "helm_release" "fluent_bit" {
  version   = "1.1.0"
  name      = "fluent-bit"
  chart     = "stable/fluent-bit"
  namespace = "logging"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${data.template_file.fluentbit_values.rendered}",
  ]  
}

data "template_file" "fluentd_values" {
  template = "${file("${path.module}/values/fluentd.values.yaml")}"

  vars {
    elasticsearch_host = "${local.elasticsearch_host}"
  }
}

resource "helm_release" "fluentd" {
  name      = "fluentd"
  chart     = "stable/fluentd"
  namespace = "logging"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${data.template_file.fluentd_values.rendered}",
  ]

  # depends_on = [
  #   "helm_release.traefik",
  # ]
}

data "kubernetes_service" "fluentd" {
  metadata {
    name      = "fluentd"
    namespace = "logging"
  }
}