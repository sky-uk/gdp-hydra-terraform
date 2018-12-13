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



# resource "helm_release" "jaeger" {
#   name      = "jaeger"
#   chart     = "stable/traefik"
#   namespace = "kube-system"

#   values = [
#     "${file("${path.module}/values/traefik.values.yaml")}",
#   ]
# }


data "template_file" "prom_values" {
  template = "${file("${path.module}/values/prometheus.worker.values.yaml.tpl")}"

  vars {
    cluster_name = "${var.cluster_name}"
  }
}

# resource "helm_release" "prometheus" {
#   count = "${var.enable_prometheus}"

#   name       = "prometheus"
#   repository = "https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/"
#   chart      = "prometheus"
#   namespace  = "monitoring"

#   # workaround to stop CI from complaining about keyring change
#   keyring = ""

#   values = [
#     "${data.template_file.prom_values.rendered}",
#   ]

#   # depends_on = [
#   #   "helm_release.prometheus_operator",
#   # ]
# }

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
