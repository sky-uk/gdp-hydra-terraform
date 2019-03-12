locals {
  elasticsearch_host = "elascticsearch-elasticsearch-coordinating-only"
}

data "template_file" "elasticsearch_values" {
  template = "${file("${path.module}/values/elasticsearch.values.yaml")}"

  vars {}
}

resource "helm_release" "elasticsearch" {
  timeout = "900"

  name      = "elascticsearch"
  chart     = "stable/elasticsearch"
  namespace = "elasticsearch"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${data.template_file.elasticsearch_values.rendered}",
  ]

  depends_on = ["null_resource.helm_init"]
}

data "template_file" "elasticsearch_exporter_values" {
  template = "${file("${path.module}/values/elasticsearch-exporter.values.yaml")}"

  vars {}
}

resource "helm_release" "elasticsearch_exporter" {
  timeout = "900"

  name      = "elascticsearch-exporter"
  chart     = "stable/elasticsearch-exporter"
  namespace = "elasticsearch"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${data.template_file.elasticsearch_exporter_values.rendered}",
  ]

  depends_on = ["null_resource.helm_init"]
}
