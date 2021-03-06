variable "host" {}
variable "cluster_ca_certificate" {}
variable "cluster_client_certificate" {}
variable "cluster_client_key" {}
variable "username" {}
variable "password" {}
variable "cluster_prefix" {}

variable "traefik_replica_count" {
  default = "3"
}

variable "kubeconfig_path" {}
variable "ingress_controller" {}

provider "kubernetes" {
  host                   = "${var.host}"
  cluster_ca_certificate = "${var.cluster_ca_certificate}"
  client_certificate     = "${var.cluster_client_certificate}"
  client_key             = "${var.cluster_client_key}"
  username               = "${var.username}"
  password               = "${var.password}"
}

# create service account for tiller - server side of Helm
resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller-service-account"
    namespace = "kube-system"
  }
}

# allow tiller do the stuff :)
resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller-cluster-rule"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.tiller.metadata.0.name}"
    api_group = ""
    namespace = "${kubernetes_service_account.tiller.metadata.0.namespace}"
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    labels = {
      createdby  = "terraform"
      datacenter = "${var.cluster_prefix}"
    }

    name = "monitoring"
  }
}

resource "kubernetes_namespace" "logging" {
  metadata {
    labels = {
      createdby  = "terraform"
      datacenter = "${var.cluster_prefix}"
    }

    name = "logging"
  }
}

resource "null_resource" "helm_init" {
  provisioner "local-exec" {
    command = "helm init --service-account ${kubernetes_service_account.tiller.metadata.0.name} --wait --kubeconfig ${var.kubeconfig_path}"
  }
}

provider "helm" {
  install_tiller  = true
  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
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

data "kubernetes_service" "ingress" {
  metadata {
    name      = "${var.ingress_controller}"
    namespace = "kube-system"
  }

  depends_on = ["null_resource.helm_init"]
}
