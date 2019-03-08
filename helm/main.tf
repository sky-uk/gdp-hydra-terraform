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

# resource "helm_release" "jaeger" {
#   name      = "jaeger"
#   chart     = "stable/traefik"
#   namespace = "kube-system"

#   values = [
#     "${file("${path.module}/values/traefik.values.yaml")}",
#   ]
# }

data "template_file" "prom_values" {
  template = "${file("${path.module}/values/prometheus.worker.values.yaml")}"

  vars {
    cluster_name = "${var.cluster_name}"
  }
}

resource "helm_release" "prometheus" {
  count = "${var.enable_prometheus}"
  name  = "prometheus"

  chart     = "stable/prometheus-operator"
  namespace = "monitoring"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${data.template_file.prom_values.rendered}",
  ]

  /*set {
    name  = "rbacEnable"
    value = "false"
  }*/

  # depends_on = [
  #   "helm_release.prometheus_operator",
  # ]
  depends_on = ["null_resource.helm_init"]
}

resource "helm_release" "registry_rewriter" {
  name      = "registry-rewriter"
  chart     = "https://github.com/lawrencegripper/MutatingAdmissionsController/releases/download/v0.1.1/registry-rewriter-0.1.0.tgz"
  namespace = "kube-system"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  set {
    name  = "containerRegistryUrl"
    value = "${var.registry_url}"
  }

  set {
    name  = "caBundle"
    value = "${base64encode(var.cluster_ca_certificate)}"
  }

  set {
    name  = "webhookImage"
    value = "lawrencegripper/imagenamemutatingcontroller:30"
  }

  set {
    name  = "imagePullSecretName"
    value = "${substr(var.cluster_name, 0, 3) == "gke" ? "" : "cluster-local-image-secret"}"
  }

  depends_on = [
    "null_resource.helm_init",
    "helm_release.prometheus",
  ]
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
  version   = "1.1.0"
  name      = "fluent-bit"
  chart     = "stable/fluent-bit"
  namespace = "logging"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${data.template_file.fluentbit_values.rendered}",
  ]

  depends_on = ["null_resource.helm_init"]
}
