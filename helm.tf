module "helm_aks1" {
  source  = "helm"
  enabled = "${var.enable_helm_deployment}"

  client_certificate     = "${base64decode(module.aks_cluster_1.cluster_client_certificate)}"
  client_key             = "${base64decode(module.aks_cluster_1.cluster_client_key)}"
  cluster_ca_certificate = "${base64decode(module.aks_cluster_1.cluster_ca)}"
  host                   = "${module.aks_cluster_1.host}"
}

module "helm_aks2" {
  source  = "helm"
  enabled = "${var.enable_helm_deployment}"

  client_certificate     = "${base64decode(module.aks_cluster_2.cluster_client_certificate)}"
  client_key             = "${base64decode(module.aks_cluster_2.cluster_client_key)}"
  cluster_ca_certificate = "${base64decode(module.aks_cluster_2.cluster_ca)}"
  host                   = "${module.aks_cluster_2.host}"
}

module "helm_gke1" {
  source  = "helm"
  enabled = "${var.enable_helm_deployment}"

  client_certificate     = "${base64decode(module.gke_cluster_1.cluster_client_certificate)}"
  client_key             = "${base64decode(module.gke_cluster_1.cluster_client_key)}"
  cluster_ca_certificate = "${base64decode(module.gke_cluster_1.cluster_ca)}"
  host                   = "${module.gke_cluster_1.host}"
}

module "helm_gke2" {
  source  = "helm"
  enabled = "${var.enable_helm_deployment}"

  client_certificate     = "${base64decode(module.gke_cluster_2.cluster_client_certificate)}"
  client_key             = "${base64decode(module.gke_cluster_2.cluster_client_key)}"
  cluster_ca_certificate = "${base64decode(module.gke_cluster_2.cluster_ca)}"
  host                   = "${module.gke_cluster_2.host}"
}
