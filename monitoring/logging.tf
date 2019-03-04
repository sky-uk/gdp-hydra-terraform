provider "helm" {
  version = "~> 0.6"

  kubernetes {
    client_certificate     = "${base64decode(module.monitoring_cluster.cluster_client_certificate)}"
    client_key             = "${base64decode(module.monitoring_cluster.cluster_client_key)}"
    cluster_ca_certificate = "${base64decode(module.monitoring_cluster.cluster_ca)}"
    host                   = "${module.monitoring_cluster.host}"
  }
}

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

  depends_on = ["helm_release.fluentd"]
}

resource "kubernetes_service" "fluentd_http" {
  metadata {
    name      = "fluentd-http"
    namespace = "logging"

    labels = {
      createdby = "terraform"
      app       = "fluentd"
    }

    annotations = {
      "traefik.ingress.kubernetes.io/buffering" = <<EOF
maxrequestbodybytes: 10485760
memrequestbodybytes: 2097153
      EOF
    }
  }

  spec {
    selector {
      app     = "fluentd"
      release = "fluentd"
    }

    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }

    type = "ClusterIP"
  }
}
