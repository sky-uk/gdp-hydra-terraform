provider "kubernetes" {
  client_certificate     = "${base64decode(module.monitoring_cluster.cluster_client_certificate)}"
  client_key             = "${base64decode(module.monitoring_cluster.cluster_client_key)}"
  cluster_ca_certificate = "${base64decode(module.monitoring_cluster.cluster_ca)}"
  host                   = "${module.monitoring_cluster.host}"
}

data "kubernetes_service" "ingress" {
  metadata {
    name      = "traefik-ingress-controller"
    namespace = "kube-system"
  }
}

resource "kubernetes_secret" "prometheus_password" {
  metadata {
    name      = "prometheus"
    namespace = "monitoring"
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
    namespace = "monitoring"

    annotations {
      "kubernetes.io/ingress.class"               = "traefik"
      "traefik.ingress.kubernetes.io/auth-type"   = "basic"
      "traefik.ingress.kubernetes.io/auth-secret" = "prometheus"
      "kubernetes.io/tls-acme"                    = "true"
      "certmanager.k8s.io/cluster-issuer"         = "letsencrypt-production"
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

    backend {
      service_name = "prometheus-master"
      service_port = 9090
    }

    rule {
      host = "${var.monitoring_dns_name}"

      http {
        path {
          path_regex = "/prometheus"

          backend {
            service_name = "prometheus-master"
            service_port = 9090
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress" "fluentd-ingress" {
  metadata {
    name      = "fluentd"
    namespace = "logging"

    annotations {
      "kubernetes.io/ingress.class"             = "traefik"
      "traefik.ingress.kubernetes.io/rule-type" = "PathPrefixStrip"
    }

    labels = {
      createdby = "terraform"
    }
  }

  spec {
    backend {
      service_name = "fluentd-ingest"
      service_port = 24220
    }

    rule {
      http {
        path {
          path_regex = "/"

          backend {
            service_name = "fluentd-ingest"
            service_port = 24220
          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "kibana_password" {
  metadata {
    name      = "kibana"
    namespace = "logging"
  }

  data {
    auth = "kibana:${bcrypt("something")}"
  }

  type = "Opaque"

  # this will stop the password updating on each apply but will also name it difficult to change the password if needed
  # it will probably be required to delete the secret manually and then re-run terraform apply
  lifecycle {
    ignore_changes = ["data.auth"]
  }
}

resource "kubernetes_ingress" "kibana-ingress" {
  metadata {
    name      = "kibana"
    namespace = "logging"

    annotations {
      "kubernetes.io/ingress.class"               = "traefik"
      "traefik.ingress.kubernetes.io/rule-type"   = "PathPrefixStrip"
      "traefik.ingress.kubernetes.io/auth-type"   = "basic"
      "traefik.ingress.kubernetes.io/auth-secret" = "kibana"
    }

    labels = {
      createdby = "terraform"
    }
  }

  spec {
    backend {
      service_name = "kibana"
      service_port = 80
    }

    rule {
      http {
        path {
          path_regex = "/kibana"

          backend {
            service_name = "kibana"
            service_port = 80
          }
        }
      }
    }
  }
}
