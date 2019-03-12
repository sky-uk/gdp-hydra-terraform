resource "local_file" "kubeconfig" {
  content  = "${var.kubeconfig}"
  filename = "${var.host}.kubeconfig"
}

resource "null_resource" "helm_init" {
  provisioner "local-exec" {
    command = "helm init --service-account ${var.tiller_service_account} --wait --kubeconfig ${local_file.kubeconfig.filename}"
  }
}

provider "helm" {
  install_tiller  = true
  service_account = "${var.tiller_service_account}"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.11.0"

  kubernetes {
    client_certificate     = "${var.client_certificate}"
    client_key             = "${var.client_key}"
    cluster_ca_certificate = "${var.cluster_ca_certificate}"
    host                   = "${var.host}"
  }
}

variable "depends_on_hack" {}

output "depends_on_hack" {
  value = "${var.depends_on_hack}"
}

data "template_file" "traefik_values" {
  template = "${file("${path.module}/values/traefik.values.yaml")}"

  vars {
    replicas_count = "${var.traefik_replica_count}"
  }
}

resource "helm_release" "traefik" {
  count     = "${var.enable_traefik}"
  name      = "traefik-ingress-controller"
  chart     = "stable/traefik"
  namespace = "kube-system"
  timeout   = "900"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  values = [
    "${data.template_file.traefik_values.rendered}",
  ]

  depends_on = ["null_resource.helm_init"]
}

resource "helm_release" "cert_manager" {
  timeout = "900"

  name      = "cert-manager"
  chart     = "stable/cert-manager"
  namespace = "kube-system"
  version   = "v0.5.2"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  /*set {
    name  = "rbac.create"
    value = "false"
  }*/

  set {
    name  = "ingressShim.defaultIssuerName"
    value = "letsencrypt-staging"
  }
  set {
    name  = "ingressShim.defaultIssuerKind"
    value = "ClusterIssuer"
  }
  depends_on = ["null_resource.helm_init"]
}

resource "helm_release" "cluster_certificates" {
  timeout = "900"

  name      = "cluster-certificates"
  chart     = "${path.module}/charts/cluster-certs"
  namespace = "kube-system"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  set {
    name  = "clusterIssuer.email"
    value = "${var.cluster_issuer_email}"
  }

  # chart is embedded in module and so path will change each time module path changes
  # it will still update when chart version is changed
  lifecycle {
    ignore_changes = ["chart"]
  }

  depends_on = [
    "null_resource.helm_init",
    "helm_release.cert_manager",
  ]
}
