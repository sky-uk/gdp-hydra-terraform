provider "helm" {
  kubernetes {
    client_certificate     = "${base64decode(module.monitoring_cluster.cluster_client_certificate)}"
    client_key             = "${base64decode(module.monitoring_cluster.cluster_client_key)}"
    cluster_ca_certificate = "${base64decode(module.monitoring_cluster.cluster_ca)}"
    host                   = "${module.monitoring_cluster.host}"
  }
}

resource "helm_release" "fluentd" {
  name      = "fluentd"
  chart     = "stable/fluentd-elasticsearch"
  namespace = "logging"

  set {
    name  = "rbac.create"
    value = "false"
  }
}
