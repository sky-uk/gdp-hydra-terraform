provider "helm" {
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

data "template_file" "traefik_values" {
  template = "${file("${path.module}/values/traefik.values.yaml.tpl")}"

  vars {
    replicas_count = "2"
  }
}

resource "helm_release" "traefik" {
  name      = "traefik-ingress-controller"
  chart     = "stable/traefik"
  namespace = "kube-system"

  values = [
    "${data.template_file.traefik_values.rendered}",
  ]
}

resource "helm_release" "fluentd" {
  name      = "fluentd"
  chart     = "stable/fluentd-elasticsearch"
  namespace = "logging"

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

  set {
    name  = "rbac.create"
    value = "false"
  }
}

data "template_file" "kibana_values" {
  template = "${file("${path.module}/values/kibana.values.yaml.tpl")}"
}

resource "helm_release" "kibana" {
  name      = "kibana"
  chart     = "stable/kibana"
  namespace = "logging"

  values = [
    "${data.template_file.kibana_values.rendered}",
  ]

  depends_on = [
    "helm_release.traefik",
  ]
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

  values = [
    "${data.template_file.fluentd_ingress_values.rendered}",
  ]

  depends_on = [
    "helm_release.traefik",
  ]
}
