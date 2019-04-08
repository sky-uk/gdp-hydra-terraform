data "template_file" "kibana_values" {
  template = "${file("${path.module}/values/kibana.values.yaml")}"
}

resource "helm_release" "kibana" {
  timeout = "900"

  version   = "0.14.7"
  name      = "kibana"
  chart     = "stable/kibana"
  namespace = "${var.logging_namespace}"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${data.template_file.kibana_values.rendered}",
  ]

  depends_on = ["null_resource.helm_init"]
}

resource "kubernetes_secret" "kibana_password" {
  metadata {
    name      = "kibana"
    namespace = "${var.logging_namespace}"
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
    namespace = "${var.logging_namespace}"

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
