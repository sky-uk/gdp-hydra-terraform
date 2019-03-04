locals {
  elasticsearch_host = "elascticsearch-elasticsearch-coordinating-only"
}

data "template_file" "elasticsearch_values" {
  template = "${file("${path.module}/values/elasticsearch.values.yaml")}"

  vars {}
}

resource "helm_release" "elasticsearch" {
  name      = "elascticsearch"
  chart     = "stable/elasticsearch"
  namespace = "elasticsearch"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${data.template_file.elasticsearch_values.rendered}",
  ]
}

data "template_file" "elasticsearch_exporter_values" {
  template = "${file("${path.module}/values/elasticsearch-exporter.values.yaml")}"

  vars {}
}

resource "helm_release" "elasticsearch_exporter" {
  name      = "elascticsearch"
  chart     = "stable/elasticsearch-exporter"
  namespace = "elasticsearch"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${data.template_file.elasticsearch_exporter_values.rendered}",
  ]
}
