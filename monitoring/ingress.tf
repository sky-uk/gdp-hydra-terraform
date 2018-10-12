provider "kubernetes" {
  client_certificate     = "${base64decode(module.monitoring_cluster.cluster_client_certificate)}"
  client_key             = "${base64decode(module.monitoring_cluster.cluster_client_key)}"
  cluster_ca_certificate = "${base64decode(module.monitoring_cluster.cluster_ca)}"
  host                   = "${module.monitoring_cluster.host}"
}

resource "kubernetes_secret" "prometheus_password" {
  metadata {
    name      = "prometheus"
    namespace = "monitoring"
  }

  data {
    auth = "prom:${bcrypt("something")}"
  }

  type = "Opaque"
}

resource "kubernetes_ingress" "prometheus-ingress" {
  metadata {
    name      = "prometheus"
    namespace = "monitoring"

    annotations {
      "kubernetes.io/ingress.class"               = "traefik"
      "traefik.ingress.kubernetes.io/auth-type"   = "basic"
      "traefik.ingress.kubernetes.io/auth-secret" = "prometheus"
    }

    labels = {
      createdby = "terraform"
    }
  }

  spec {
    backend {
      service_name = "prometheus-master"
      service_port = 9090
    }

    rule {
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
