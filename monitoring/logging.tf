provider "helm" {
  version = "~> 0.6"

  kubernetes {
    client_certificate     = "${base64decode(module.monitoring_cluster.cluster_client_certificate)}"
    client_key             = "${base64decode(module.monitoring_cluster.cluster_client_key)}"
    cluster_ca_certificate = "${base64decode(module.monitoring_cluster.cluster_ca)}"
    host                   = "${module.monitoring_cluster.host}"
  }
}

locals {
  elasticsearch_host = "elascticsearch-elasticsearch-coordinating-only"
}

data "template_file" "traefik_values" {
  template = "${file("${path.module}/values/traefik.values.yaml.tpl")}"

  vars {
    replicas_count = "2"
  }
}

resource "helm_release" "traefik" {
  name      = "traefik-ingress-controller"
  chart     = "stable/traefik"
  namespace = "kube-system"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${data.template_file.traefik_values.rendered}",
  ]
}

resource "helm_release" "fluentd" {
  name      = "fluentd"
  chart     = "stable/fluentd-elasticsearch"
  namespace = "logging"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  set {
    name  = "rbac.create"
    value = "false"
  }

  set {
    name  = "elasticsearch.host"
    value = "${local.elasticsearch_host}"
  }
}

resource "kubernetes_daemonset" "elasticsetup" {
  metadata {
    namespace = "logging"
    name = "sysctl-conf"
  }

  spec {
    selector {
      app = "sysctl-conf"
    }

    template {
      metadata {
        labels {
          app = "sysctl-conf"
        }
      }

      spec {
        container {
          image = "busybox:1.29"
          name = "sysctl-conf"

          command = ["sysctl", "-w", "vm.max_map_count=262166", "&&", "while true; do", "sleep 86400;", "done"]

          resources {
            requests {
              cpu = "10m"
              memory = "50Mi"
            }

            limits {
              cpu = "10m"
              memory = "50Mi"
            }
          }

          security_context {
            privileged = "true"
          }
        }
      }
    }
  }
}

resource "helm_release" "elasticsearch" {
  name       = "elascticsearch"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "elasticsearch"
  namespace  = "logging"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  set {
    name  = "rbac.create"
    value = "false"
  }

  depends_on = [
    "kubernetes_daemonset.elasticsetup",
  ]
}

data "template_file" "kibana_values" {
  template = "${file("${path.module}/values/kibana.values.yaml.tpl")}"
}

resource "helm_release" "kibana" {
  version   = "0.14.7"
  name      = "kibana"
  chart     = "stable/kibana"
  namespace = "logging"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${data.template_file.kibana_values.rendered}",
  ]

  depends_on = [
    "helm_release.traefik",
  ]
}

data "template_file" "fluentd_ingress_values" {
  template = "${file("${path.module}/values/fluentd-ingress.values.yaml")}"

  vars {
    elasticsearch_host = "${local.elasticsearch_host}"
  }
}

resource "helm_release" "fluentd_ingest" {
  name      = "fluentd-ingest"
  chart     = "stable/fluentd"
  namespace = "logging"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${data.template_file.fluentd_ingress_values.rendered}",
  ]

  depends_on = [
    "helm_release.traefik",
  ]
}
