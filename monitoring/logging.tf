data "template_file" "fluentbit_values" {
  template = "${file("${path.module}/values/fluent-bit.values.yaml")}"
}

# fluent-bit installed as a deamonset to colelct logs from the cluster and send them to the 
# fluentd instance that will push them to elasticsearch
resource "helm_release" "fluent_bit" {
  timeout = "900"

  version   = "1.1.0"
  name      = "fluent-bit"
  chart     = "stable/fluent-bit"
  namespace = "${kubernetes_namespace.logging.metadata.0.name}"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${data.template_file.fluentbit_values.rendered}",
  ]

  depends_on = ["null_resource.helm_init"]
}

data "template_file" "fluentd_values" {
  template = "${file("${path.module}/values/fluentd.values.yaml")}"

  vars {
    elasticsearch_host = "${local.elasticsearch_host}"
  }
}

resource "helm_release" "fluentd" {
  timeout = "900"

  name      = "fluentd"
  chart     = "stable/fluentd"
  namespace = "${kubernetes_namespace.logging.metadata.0.name}"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${data.template_file.fluentd_values.rendered}",
  ]

  # depends_on = [
  #   "helm_release.traefik",
  # ]
  depends_on = ["null_resource.helm_init"]
}

data "kubernetes_service" "fluentd" {
  metadata {
    name      = "fluentd"
    namespace = "${kubernetes_namespace.logging.metadata.0.name}"
  }

  depends_on = ["helm_release.fluentd"]
}

resource "kubernetes_service" "fluentd_http" {
  metadata {
    name      = "fluentd-http"
    namespace = "${kubernetes_namespace.logging.metadata.0.name}"

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
