variable "image_pull_server" {
  default = ""
}

variable "image_pull_username" {
  default = ""
}

variable "image_pull_password" {
  default = ""
}

variable "enable_image_pull_secret" {
  default = 0
}

variable "cluster_link" {}

resource "kubernetes_service" "ingress_service" {
  metadata {
    name      = "terraform-ingress2"
    namespace = "kube-system"

    labels = {
      createdby = "terraform"
      cluster   = "${var.cluster_link}"
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
      cluster   = "${var.cluster_link}"
    }
  }

  data {
    ".dockerconfigjson" = "${data.template_file.image_pull_config.rendered}"
  }
}

output "cluster_ingress_ip" {
  value = "${kubernetes_service.ingress_service.load_balancer_ingress.0.ip}"
}
