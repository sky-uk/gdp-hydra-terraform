provider "kubernetes" {
  host                   = "${var.host}"
  cluster_ca_certificate = "${var.cluster_ca_certificate}"
  client_certificate     = "${var.cluster_client_certificate}"
  client_key             = "${var.cluster_client_key}"
  username               = "${var.username}"
  password               = "${var.password}"
}

provider "helm" {
  install_tiller  = true
  service_account = "${var.tiller_service_account}"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.11.0"

  kubernetes {
    host                   = "${var.host}"
    cluster_ca_certificate = "${var.cluster_ca_certificate}"
    client_certificate     = "${var.cluster_client_certificate}"
    client_key             = "${var.cluster_client_key}"
    username               = "${var.username}"
    password               = "${var.password}"
  }
}
