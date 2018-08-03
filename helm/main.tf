provider "helm" {
  kubernetes {
    client_certificate     = "${var.client_certificate}"
    client_key             = "${var.client_key}"
    cluster_ca_certificate = "${var.cluster_ca_certificate}"
    host                   = "${var.host}"
  }
}

resource "helm_release" "traefik" {
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

resource "helm_release" "prometheus_operator" {
  name       = "prometheus-operator"
  repository = "https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/"
  chart      = "prometheus-operator"
  namespace  = "monitoring"

  set {
    name  = "rbacEnable"
    value = "false"
  }
}

resource "helm_release" "kube_prometheus" {
  name       = "kube-prometheus"
  repository = "https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/"
  chart      = "kube-prometheus"
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
  name      = "prometheus-slaves"
    repository = "https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/"
  chart     = "prometheus"
  namespace = "monitoring"

  values = [
    "${file("${path.module}/values/prometheus.slaves.values.yaml")}",
  ]

  depends_on = [
    "helm_release.prometheus_operator",
  ]
}

resource "helm_release" "prometheus_master" {
  name      = "prometheus-master"
    repository = "https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/"
  chart     = "prometheus"
  namespace = "monitoring"

  values = [
    "${file("${path.module}/values/prometheus.master.values.yaml")}",
  ]

  depends_on = [
    "helm_release.prometheus_operator",
  ]
}