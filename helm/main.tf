provider "helm" {
  version = "~> 0.6"

  kubernetes {
    client_certificate     = "${var.client_certificate}"
    client_key             = "${var.client_key}"
    cluster_ca_certificate = "${var.cluster_ca_certificate}"
    host                   = "${var.host}"
  }
}

variable "depends_on_hack" {}

output "depends_on_hack" {
  value = "${var.depends_on_hack}"
}

data "template_file" "traefik_values" {
  template = "${file("${path.module}/values/traefik.values.yaml.tpl")}"

  vars {
    replicas_count = "${var.traefik_replica_count}"
  }
}

resource "helm_release" "traefik" {
  count     = "${var.enable_traefik}"
  name      = "traefik-ingress-controller"
  chart     = "stable/traefik"
  namespace = "kube-system"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${data.template_file.traefik_values.rendered}",
  ]
}

# resource "helm_release" "jaeger" {
#   name      = "jaeger"
#   chart     = "stable/traefik"
#   namespace = "kube-system"

#   values = [
#     "${file("${path.module}/values/traefik.values.yaml")}",
#   ]
# }

resource "helm_release" "prometheus_operator" {
  count = "${var.enable_prometheus}"

  name       = "prometheus-operator"
  repository = "https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/"
  chart      = "prometheus-operator"
  namespace  = "monitoring"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  set {
    name  = "rbacEnable"
    value = "false"
  }
}

data "template_file" "prom_values" {
  template = "${file("${path.module}/values/prometheus.slaves.values.yaml.tpl")}"

  vars {
    cluster_name = "${var.cluster_name}"
  }
}

resource "helm_release" "prometheus_slaves" {
  count = "${var.enable_prometheus}"

  name       = "prometheus-slaves"
  repository = "https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/"
  chart      = "prometheus"
  namespace  = "monitoring"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${data.template_file.prom_values.rendered}",
  ]

  depends_on = [
    "helm_release.prometheus_operator",
  ]
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
    "helm_release.prometheus_operator",
  ]
}

# https://github.com/helm/charts/tree/master/stable/fluent-bit
resource "helm_release" "fluent_bit" {
  name      = "fluent-bit"
  chart     = "stable/fluent-bit"
  namespace = "logging"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  set {
    name  = "rbac.create"
    value = "false"
  }

  set {
    name  = "backend.forward.host"
    value = "sghydra-logging-ykqvkzid.northeurope.azurecontainer.io"
  }

  set {
    name  = "backend.forward.port"
    value = "24224"
  }
}
