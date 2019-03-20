resource "kubernetes_service" "workers" {
  metadata {
    name      = "hydra-workers"
    namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"

    labels {
      hydra_role = "worker"
    }
  }

  spec {
    external_name = "hydra.workers.local"
    type          = "ExternalName"
  }
}

resource "kubernetes_secret" "prometheus_workers_password" {
  metadata {
    name      = "prometheus-workers"
    namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"
  }

  data {
    username = "${var.prometheus_scrape_credentials["username"]}"
    password = "${var.prometheus_scrape_credentials["password"]}"
  }

  type = "Opaque"
}

resource "helm_release" "prometheus_master" {
  timeout = "900"

  name      = "prometheus-master"
  chart     = "stable/prometheus-operator"
  namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${file("${path.module}/values/prometheus.master.values.yaml")}",
  ]

  # depends_on = [
  #   "helm_release.prometheus_operator",
  # ]
  depends_on = ["null_resource.helm_init"]
}

resource "helm_release" "worker_endpoints" {
  timeout = "900"

  name      = "workerendpoints"
  chart     = "${path.module}/charts/monitoringendpoints"
  namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  set {
    name  = "workers"
    value = "{${join(",", values(var.cluster_ips))}}"
  }

  # chart is embedded in module and so path will change each time module path changes
  # it will still update when chart version is changed
  lifecycle {
    ignore_changes = ["chart"]
  }

  depends_on = ["null_resource.helm_init"]
}

resource "kubernetes_secret" "prometheus_password" {
  metadata {
    name      = "prometheus"
    namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"
  }

  data {
    auth = "prom:${bcrypt("${var.prometheus_ui_password}")}"
  }

  type = "Opaque"

  # this will stop the password updating on each apply but will also name it difficult to change the password if needed
  # it will probably be required to delete the secret manually and then re-run terraform apply
  lifecycle {
    ignore_changes = ["data.auth"]
  }
}

resource "kubernetes_ingress" "prometheus-ingress" {
  metadata {
    name      = "prometheus"
    namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"

    annotations {
      "kubernetes.io/ingress.class"               = "traefik"
      "traefik.ingress.kubernetes.io/auth-type"   = "basic"
      "traefik.ingress.kubernetes.io/auth-secret" = "prometheus"
      "kubernetes.io/tls-acme"                    = "true"
      "certmanager.k8s.io/cluster-issuer"         = "letsencrypt-staging"
      "ingress.kubernetes.io/ssl-redirect"        = "true"
    }

    labels = {
      createdby = "terraform"
    }
  }

  spec {
    tls {
      hosts       = ["${var.monitoring_dns_name}"]
      secret_name = "${replace(var.monitoring_dns_name,".","-")}-tls"
    }

    rule {
      host = "${var.monitoring_dns_name}"

      http {
        path {
          path_regex = "/prometheus"

          backend {
            service_name = "prometheus-master-promethe-prometheus"
            service_port = 9090
          }
        }
      }
    }
  }
}
