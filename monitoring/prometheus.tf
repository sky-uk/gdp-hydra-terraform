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

resource "kubernetes_service" "workers" {
  metadata {
    name = "hydra-workers"

    labels = {
      hydra_role = "worker"
    }

    namespace = "monitoring"
  }

  spec {
    external_name = "${var.cluster_ips["aks_cluster_1"]}"
    type          = "ExternalName"
  }
}

resource "helm_release" "prometheus_master" {
  name       = "prometheus-master"
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
  name       = "workerendpoints"
  chart      = "${path.module}/charts/monitoringendpoints"
  namespace  = "monitoring"

  set {
    name = "workers" 
    value = "{${join(",", values(var.cluster_ips))}}"
  }
}