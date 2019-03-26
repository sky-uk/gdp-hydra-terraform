data "template_file" "jaeger_values" {
  template = "${file("${path.module}/values/jaeger.values.yaml")}"

  vars {
    monitoring_dns_name = "${var.monitoring_dns_name}"
  }
}

#resource "helm_release" "jaeger" {
#  timeout = "900"
#
#  name      = "jaeger-operator"
#  chart     = "stable/jaeger-operator"
#  namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"
#
#  # workaround to stop CI from complaining about keyring change
#  keyring = ""
#
##  values = [
##    "${data.template_file.jaeger_values.rendered}",
##  ]
#
#  depends_on = [
#    "helm_release.elasticsearch",
#  ]
#}

resource "kubernetes_ingress" "jaeger-ui" {
  metadata {
    name      = "jaeger-ui"
    namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"

    annotations {
      "kubernetes.io/ingress.class"               = "traefik"
      "traefik.ingress.kubernetes.io/auth-type"   = "basic"
      "traefik.ingress.kubernetes.io/auth-secret" = "prometheus"
      "kubernetes.io/tls-acme"                    = "true"
      "certmanager.k8s.io/cluster-issuer"         = "letsencrypt-${var.letsencrypt_environment}"
      "ingress.kubernetes.io/ssl-redirect"        = "true"
      "traefik.ingress.kubernetes.io/rule-type"   = "PathPrefixStrip"
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
          path_regex = "/jaeger"

          backend {
            service_name = "jaeger-query"
            service_port = 16686
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress" "jaeger-collector" {
  metadata {
    name      = "jaeger-collector"
    namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"

    annotations {
      "kubernetes.io/ingress.class" = "traefik"

      # "traefik.ingress.kubernetes.io/auth-type"   = "basic"
      # "traefik.ingress.kubernetes.io/auth-secret" = "prometheus"
      "kubernetes.io/tls-acme" = "true"

      "certmanager.k8s.io/cluster-issuer"       = "letsencrypt-${var.letsencrypt_environment}"
      "ingress.kubernetes.io/ssl-redirect"      = "true"
      "traefik.ingress.kubernetes.io/rule-type" = "PathPrefixStrip"
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
          path_regex = "/jaeger-collector"

          backend {
            service_name = "jaeger-collector"
            service_port = 14268
          }
        }
      }
    }
  }
}
