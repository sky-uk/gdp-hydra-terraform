provider "helm" {
  kubernetes {
    client_certificate     = "${var.client_certificate}"
    client_key             = "${var.client_key}"
    cluster_ca_certificate = "${var.cluster_ca_certificate}"
    host                   = "${var.host}"
  }
}

resource "helm_release" "traefik" {
  count     = "${var.enable_traefik}"
  name      = "traefik-ingress-controller"
  chart     = "stable/traefik"
  namespace = "kube-system"

  values = [
    "${file("${path.module}/values/traefik.values.yaml")}",
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

resource "helm_repository" "coreos" {
  count = "${var.enable_prometheus}"

  name = "coreos"
  url  = "https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/"
}

resource "helm_release" "prometheus_operator" {
  count = "${var.enable_prometheus}"

  name       = "prometheus-operator"
  repository = "${helm_repository.coreos.metadata.0.name}"
  chart      = "coreos/prometheus-operator"
  namespace  = "monitoring"

  set {
    name  = "rbacEnable"
    value = "false"
  }
}

resource "helm_release" "kube_prometheus" {
  count = "${var.enable_prometheus}"

  name       = "kube-prometheus"
  repository = "${helm_repository.coreos.metadata.0.name}"
  chart      = "coreos/kube-prometheus"
  namespace  = "monitoring"

  set {
    name  = "global.rbacEnable"
    value = "false"
  }

  depends_on = [
    "helm_release.prometheus_operator",
  ]
}

resource "helm_release" "prometheus_slaves" {
  count = "${var.enable_prometheus}"

  name      = "prometheus-slaves"
  chart     = "coreos/prometheus"
  namespace = "monitoring"

  values = [
    "${file("${path.module}/values/prometheus.slaves.values.yaml")}",
  ]

  depends_on = [
    "helm_release.prometheus_operator",
  ]
}

