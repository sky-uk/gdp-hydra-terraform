resource "local_file" "kubeconfig" {
  content  = "${var.kubeconfig}"
  filename = "${var.host}.kubeconfig"
}

resource "null_resource" "helm_init" {
  provisioner "local-exec" {
    command = "helm init --service-account ${var.tiller_service_account} --wait --kubeconfig ${local_file.kubeconfig.filename}"
  }
}

provider "helm" {
  kubernetes {
    client_certificate     = "${var.client_certificate}"
    client_key             = "${var.client_key}"
    cluster_ca_certificate = "${var.cluster_ca_certificate}"
    host                   = "${var.host}"
  }

  install_tiller  = true
  service_account = "${var.tiller_service_account}"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.11.0"
}

variable "depends_on_hack" {}

output "depends_on_hack" {
  value = "${var.depends_on_hack}"
}

resource "helm_release" "jaeger" {
  name       = "jaeger"
  chart      = "stable/jaeger-operator"
  namespace  = "monitoring"
  depends_on = ["null_resource.helm_init"]
}

data "template_file" "prom_values" {
  template = "${file("${path.module}/values/prometheus.worker.values.yaml")}"

  vars {
    cluster_name = "${var.cluster_name}"
  }
}

resource "helm_release" "prometheus" {
  timeout = "900"

  count = "${var.enable_prometheus}"
  name  = "prometheus"

  chart     = "stable/prometheus-operator"
  namespace = "${var.monitoring_namespace}"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${data.template_file.prom_values.rendered}",
  ]

  set {
    name  = "rbacEnable"
    value = "false"
  }

  # depends_on = [
  #   "helm_release.prometheus_operator",
  # ]
  depends_on = ["null_resource.helm_init"]
}

data "template_file" "fluentbit_values" {
  template = "${file("${path.module}/values/fluent-bit.values.yaml")}"

  vars {
    fluentd_ingress_ip  = "${var.fluentd_ingress_ip}"
    monitoring_dns_name = "${var.monitoring_dns_name}"
  }
}

# https://github.com/helm/charts/tree/master/stable/fluent-bit
resource "helm_release" "fluent_bit" {
  timeout = "900"

  version   = "1.1.0"
  name      = "fluent-bit"
  chart     = "stable/fluent-bit"
  namespace = "${var.logging_namespace}"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${data.template_file.fluentbit_values.rendered}",
  ]

  depends_on = ["null_resource.helm_init"]
}
