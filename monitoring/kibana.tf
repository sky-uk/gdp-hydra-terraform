data "template_file" "kibana_values" {
  template = "${file("${path.module}/values/kibana.values.yaml")}"
}

resource "helm_release" "kibana" {
  version   = "0.14.7"
  name      = "kibana"
  chart     = "stable/kibana"
  namespace = "${kubernetes_namespace.logging.metadata.0.name}"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${data.template_file.kibana_values.rendered}",
  ]

  # depends_on = [
  #   "helm_release.traefik",
  # ]
  depends_on = ["null_resource.helm_init"]
}

resource "kubernetes_secret" "kibana_password" {
  metadata {
    name      = "kibana"
    namespace = "${kubernetes_namespace.logging.metadata.0.name}"
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

  depends_on = ["kubernetes_namespace.logging"]
}

resource "kubernetes_ingress" "kibana-ingress" {
  metadata {
    name      = "kibana"
    namespace = "${kubernetes_namespace.logging.metadata.0.name}"

    annotations {
      "kubernetes.io/ingress.class"               = "traefik"
      "traefik.ingress.kubernetes.io/rule-type"   = "PathPrefixStrip"
      "traefik.ingress.kubernetes.io/auth-type"   = "basic"
      "traefik.ingress.kubernetes.io/auth-secret" = "kibana"
      "ingress.kubernetes.io/ssl-redirect"        = "true"
    }

    labels = {
      createdby = "terraform"
    }
  }

  spec {
    rule {
      host = "${var.monitoring_dns_name}"

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
