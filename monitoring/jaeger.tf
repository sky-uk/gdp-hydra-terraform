data "template_file" "jaeger_values" {
  template = "${file("${path.module}/values/jaeger.values.yaml")}"

  vars {
    monitoring_dns_name = "${var.monitoring_dns_name}"
  }
}

data "helm_repository" "incubator" {
  name       = "incubator"
  url        = "https://kubernetes-charts-incubator.storage.googleapis.com/"
  depends_on = ["null_resource.helm_init"]
}

resource "helm_release" "jaeger" {
  name       = "jaeger"
  chart      = "jaeger"
  namespace  = "monitoring"
  repository = "${data.helm_repository.incubator.metadata.0.name}"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${data.template_file.jaeger_values.rendered}",
  ]

  depends_on = [
    "helm_release.elasticsearch",
  ]
}

resource "kubernetes_ingress" "jaeger-ui" {
  metadata {
    name      = "jaeger-ui"
    namespace = "monitoring"

    annotations {
      "kubernetes.io/ingress.class"               = "traefik"
      "traefik.ingress.kubernetes.io/auth-type"   = "basic"
      "traefik.ingress.kubernetes.io/auth-secret" = "prometheus"
      "kubernetes.io/tls-acme"                    = "true"
      "certmanager.k8s.io/cluster-issuer"         = "letsencrypt-production"
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
            service_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress" "jaeger-collector" {
  metadata {
    name      = "jaeger-collector"
    namespace = "monitoring"

    annotations {
      "kubernetes.io/ingress.class" = "traefik"

      # "traefik.ingress.kubernetes.io/auth-type"   = "basic"
      # "traefik.ingress.kubernetes.io/auth-secret" = "prometheus"
      "kubernetes.io/tls-acme" = "true"

      "certmanager.k8s.io/cluster-issuer"       = "letsencrypt-production"
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
