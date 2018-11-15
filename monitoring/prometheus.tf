resource "helm_release" "prometheus_operator" {
  name       = "prometheus-operator"
  version    = "0.0.29"
  repository = "https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/"
  chart      = "prometheus-operator"
  namespace  = "monitoring"

  set {
    name  = "rbacEnable"
    value = "false"
  }
}

resource "kubernetes_service" "workers" {
  metadata {
    name      = "hydra-workers"
    namespace = "monitoring"
  }

  spec {
    external_name = "hydra.workers.local"
    type          = "ExternalName"
  }
}

resource "kubernetes_secret" "prometheus_workers_password" {
  metadata {
    name      = "prometheus-workers"
    namespace = "monitoring"
  }

  data {
    username = "${var.prometheus_scrape_credentials["username"]}"
    password = "${var.prometheus_scrape_credentials["password"]}"
  }

  type = "Opaque"
}


resource "helm_release" "prometheus_master" {
  name       = "prometheus-master"
  version    = "0.0.51"
  repository = "https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/"
  chart      = "prometheus"
  namespace  = "monitoring"

  values = [
    "${file("${path.module}/values/prometheus.master.values.yaml")}",
  ]

  depends_on = [
    "helm_release.prometheus_operator",
  ]
}

resource "helm_release" "worker_endpoints" {
  name      = "workerendpoints"
  chart     = "${path.module}/charts/monitoringendpoints"
  namespace = "monitoring"

  set {
    name  = "workers"
    value = "{${join(",", values(var.cluster_ips))}}"
  }
}
