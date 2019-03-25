variable "cluster_ca_certificate" {}
variable "host" {}

provider "kubernetes" {
  cluster_ca_certificate = "${var.cluster_ca_certificate}"
  host                   = "${var.host}"
}

resource "kubernetes_namespace" "ns" {
  metadata {
    labels = {
      createdby = "terraform"
    }

    name = "example"
  }
}

resource "kubernetes_ingress" "example" {
  metadata {
    name = "example"

    labels = {
      createdby = "terraform"
    }

    namespace = "${kubernetes_namespace.ns.metadata.0.name}"

    annotations {
      "kubernetes.io/ingress.class"          = "traefik"
      "ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    rule {
      http {
        path {
          path_regex = "/example"

          backend {
            service_name = "echoserver"
            service_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "echoserver" {
  metadata {
    name = "echoserver"

    labels = {
      createdby = "terraform"
    }

    namespace = "${kubernetes_namespace.ns.metadata.0.name}"
  }

  spec {
    selector {
      app = "echoserver"
    }

    port {
      port        = 8080
      target_port = 8080
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "echoserver" {
  metadata {
    name = "echoserver"

    labels = {
      createdby = "terraform"
    }

    namespace = "${kubernetes_namespace.ns.metadata.0.name}"
  }

  spec {
    selector {
      app = "echoserver"
    }

    template {
      metadata {
        labels {
          app = "echoserver"
        }
      }

      spec {
        container {
          name  = "echoserver"
          image = "gcr.io/google_containers/echoserver:1.4"

          port {
            container_port = 8080
          }
        }
      }
    }
  }
}
