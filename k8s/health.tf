resource "kubernetes_namespace" "healthcheck" {
  metadata {
    labels = {
      createdby  = "terraform"
      datacenter = "${var.cluster_name}"
    }

    name = "healthcheck"
  }
}

resource "kubernetes_ingress" "hc-ingress" {
  metadata {
    name      = "hc-ingress"
    namespace = "${kubernetes_namespace.healthcheck.metadata.0.name}"

    annotations {
      "kubernetes.io/ingress.class"          = "traefik"
      "ingress.kubernetes.io/rewrite-target" = "/healthz"
    }

    labels = {
      createdby  = "terraform"
      datacenter = "${var.cluster_name}"
    }
  }

  spec {
    backend {
      service_name = "hc-service"
      service_port = 8080
    }

    rule {
      http {
        path {
          path_regex = "/healthz"

          backend {
            service_name = "hc-service"
            service_port = 5000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "hc-service" {
  metadata {
    name      = "hc-service"
    namespace = "${kubernetes_namespace.healthcheck.metadata.0.name}"

    labels = {
      createdby  = "terraform"
      datacenter = "${var.cluster_name}"
    }
  }

  spec {
    selector {
      app = "hc-app"
    }

    port {
      port        = 5000
      target_port = 5000
    }
  }
}

resource "kubernetes_deployment" "hc-app" {
  metadata {
    name      = "hc-app"
    namespace = "${kubernetes_namespace.healthcheck.metadata.0.name}"

    labels = {
      createdby  = "terraform"
      datacenter = "${var.cluster_name}"
    }
  }

  spec {
    selector {
      app = "hc-app"
    }

    template {
      metadata {
        labels {
          app        = "hc-app"
          createdby  = "terraform"
          datacenter = "${var.cluster_name}"
        }
      }

      spec {
        container {
          name  = "hc"
          image = "emrekenci/k8s-healthcheck:v1"

          port {
            container_port = 5000
          }

          env {
            name  = "USERNAME"
            value = "admin"
          }

          env {
            name  = "PASSWORD"
            value = "${var.monitoring_endpoint_password}"
          }

          env {
            name  = "CACHE_DURATION_IN_SECONDS"
            value = "30"
          }

          env {
            name  = "NODE_ENV"
            value = "production"
          }

          env {
            # Use this to exclude some monitors from the result. Must be string deliminated. 
            # Add the property name as you see in the result json .
            # Ex: "apiServer,etcd,controllerManager,scheduler,nodes,deployments"
            name = "EXCLUDE"

            value = "controllerManager,scheduler"
          }

          env {
            name  = "DEPLOYMENTS_NAMESPACE"
            value = "default"
          }
        }
      }
    }
  }
}
