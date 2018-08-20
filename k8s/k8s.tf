provider "kubernetes" {
  client_certificate     = "${var.cluster_client_certificate}"
  client_key             = "${var.cluster_client_key}"
  cluster_ca_certificate = "${var.cluster_ca_certificate}"
  host                   = "${var.host}"
}

resource "kubernetes_service" "ingress_service" {
  metadata {
    name      = "traefik-ingress-controller"
    namespace = "kube-system"

    labels = {
      createdby = "terraform"
      app       = "traefik"
    }
  }

  spec {
    selector {
      app     = "traefik"
      release = "traefik-ingress-controller"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 80
    }

    port {
      name        = "https"
      port        = 443
      target_port = 443
    }

    port {
      name        = "metrics"
      port        = 8080
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

data "template_file" "image_pull_config" {
  template = "${file("${path.module}/templates/imagepullconfig.json.tpl")}"

  vars {
    username = "${var.image_pull_username}"
    password = "${var.image_pull_password}"
    server   = "${var.image_pull_server}"
    auth     = "${base64encode(format("%s:%s", var.image_pull_username, var.image_pull_password))}"
  }
}

resource "kubernetes_secret" "image_pull_secret" {
  count = "${var.enable_image_pull_secret}"
  type  = "kubernetes.io/dockerconfigjson"

  metadata {
    name = "image-pull-secret-acr"

    labels = {
      createdby = "terraform"
    }
  }

  data {
    ".dockerconfigjson" = "${data.template_file.image_pull_config.rendered}"
  }
}
