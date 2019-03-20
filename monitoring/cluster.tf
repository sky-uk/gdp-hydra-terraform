variable "azure_node_ssh_key" {
  description = "SSH key for nodes created in AKS. This SSH key is used as the access key for each of the nodes created in AKS. Keep this safe as it will allow you to remote onto nodes should you need to. You can create a new key with `ssh-keygen -f ./id_rsa -N '' -C aks-key`"
}

variable "azure_client_id" {}
variable "azure_client_secret" {}

variable "node_sku" {}

variable "azure_resource_location" {}

module "monitoring_cluster" {
  source = "../gke"

  project_name = "${var.project_name}"
  tags         = "${var.tags}"

  cluster_prefix     = "${var.cluster_prefix}"
  region             = "europe-west2-a"
  google_project     = "${var.google_project}"
  kubernetes_version = "${var.kubernetes_version}"
  node_count         = "${var.node_count}"
  machine_type       = "${var.machine_type}"
}

module "cluster_services_monitoring" {
  source = "../cluster_services"

  enable_traefik = true

  client_certificate     = "${base64decode(module.monitoring_cluster.cluster_client_certificate)}"
  client_key             = "${base64decode(module.monitoring_cluster.cluster_client_key)}"
  cluster_ca_certificate = "${base64decode(module.monitoring_cluster.cluster_ca)}"
  kubeconfig             = "${module.monitoring_cluster.kubeconfig}"
  host                   = "${module.monitoring_cluster.host}"
  cluster_name           = "gke2"
  tiller_service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
  traefik_replica_count  = "2"

  cluster_issuer_email = "${var.cluster_issuer_email}"

  depends_on_hack = "${data.kubernetes_service.ingress.load_balancer_ingress.0.ip}"
}

data "kubernetes_service" "ingress" {
  metadata {
    name      = "traefik-ingress-controller"
    namespace = "kube-system"
  }

  depends_on = ["null_resource.cluster"]
}

resource "null_resource" "cluster" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    cluster_instance_ids = "${module.monitoring_cluster.host}"
  }

  provisioner "local-exec" {
    command = "echo ${module.cluster_services_monitoring.helm_traefik_name}"
  }
}

variable "cluster_prefix" {}

variable "google_project" {}
variable "kubernetes_version" {}

variable "machine_type" {}

variable "node_count" {
  default = 2
}
