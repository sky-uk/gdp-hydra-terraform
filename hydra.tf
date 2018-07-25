provider "azurerm" {
  client_id       = "${var.azure_client_id}"
  client_secret   = "${var.azure_client_secret}"
  subscription_id = "${var.azure_subscription_id}"
  tenant_id       = "${var.azure_tenant_id}"
}

// Configure the Google Cloud provider
provider "google" {
  credentials = "${base64decode(var.gcp_creds_base64)}"
}

provider "akamai" {
  host          = "${var.akamai_host}"
  access_token  = "${var.akamai_access_token}"
  client_token  = "${var.akamai_client_token}"
  client_secret = "${var.akamai_client_secret}"
}

provider "kubernetes" {
  alias = "aks_1"

  client_certificate     = "${base64decode(module.aks_cluster_1.cluster_client_certificate)}"
  client_key             = "${base64decode(module.aks_cluster_1.cluster_client_key)}"
  cluster_ca_certificate = "${base64decode(module.aks_cluster_1.cluster_ca)}"
  host                   = "${module.aks_cluster_1.host}"
}

provider "kubernetes" {
  alias = "aks_2"

  client_certificate     = "${base64decode(module.aks_cluster_2.cluster_client_certificate)}"
  client_key             = "${base64decode(module.aks_cluster_2.cluster_client_key)}"
  cluster_ca_certificate = "${base64decode(module.aks_cluster_2.cluster_ca)}"
  host                   = "${module.aks_cluster_2.host}"
}

provider "kubernetes" {
  alias = "gke_2"

  client_certificate     = "${base64decode(module.gke_cluster_2.cluster_client_certificate)}"
  client_key             = "${base64decode(module.gke_cluster_2.cluster_client_key)}"
  cluster_ca_certificate = "${base64decode(module.gke_cluster_2.cluster_ca)}"
  host                   = "${module.gke_cluster_2.host}"
}

provider "kubernetes" {
  alias = "gke_1"

  client_certificate     = "${base64decode(module.gke_cluster_1.cluster_client_certificate)}"
  client_key             = "${base64decode(module.gke_cluster_1.cluster_client_key)}"
  cluster_ca_certificate = "${base64decode(module.gke_cluster_1.cluster_ca)}"
  host                   = "${module.gke_cluster_1.host}"
}

module "acr" {
  source = "acr"

  resource_group_name     = "${local.resource_group_name_acr}"
  resource_group_location = "${var.azure_resource_locations[0]}"
  project_name            = "${var.project_name}"
}

module "aks_cluster_1" {
  source = "aks"

  cluster_prefix      = "aks-cluster"
  resource_group_name = "${local.resource_group_name_clusters}"

  //Defaults to using current ssh key: recomend changing as needed
  linux_admin_username      = "aks"
  linux_admin_ssh_publickey = "${var.azure_node_ssh_key}"

  client_id          = "${var.azure_client_id}"
  client_secret      = "${var.azure_client_secret}"
  kubernetes_version = "${var.kubernetes_version}"
  node_count         = "${var.node_count}"
  node_sku           = "${local.aks_node}"

  region = "${var.azure_resource_locations[0]}"
}

module "k8s_config_aks_1" {
  source = "k8s"

  providers {
    "kubernetes" = "kubernetes.aks_1"
  }

  enable_image_pull_secret = true
  image_pull_server        = "${module.acr.url}"
  image_pull_username      = "${module.acr.username}"
  image_pull_password      = "${module.acr.password}"

  # workaround for issue with the kubernetes provider constructing cluster name here rather than passing it from the module
  cluster_link = "aks-cluster-westeurope"
}

module "aks_cluster_2" {
  source = "aks"

  cluster_prefix      = "aks-cluster"
  resource_group_name = "${local.resource_group_name_clusters}"

  //Defaults to using current ssh key: recomend changing as needed
  linux_admin_username      = "aks"
  linux_admin_ssh_publickey = "${var.azure_node_ssh_key}"

  client_id          = "${var.azure_client_id}"
  client_secret      = "${var.azure_client_secret}"
  kubernetes_version = "${var.kubernetes_version}"
  node_count         = "${var.node_count}"
  node_sku           = "${local.aks_node}"

  region = "${var.azure_resource_locations[1]}"
}

module "k8s_config_aks_2" {
  source = "k8s"

  providers {
    "kubernetes" = "kubernetes.aks_2"
  }

  enable_image_pull_secret = true
  image_pull_server        = "${module.acr.url}"
  image_pull_username      = "${module.acr.username}"
  image_pull_password      = "${module.acr.password}"

  # workaround for issue with the kubernetes provider constructing cluster name here rather than passing it from the module
  cluster_link = "aks-cluster-northeurope"
}

module "gke_cluster_1" {
  source = "gke"

  organization       = "0"
  cluster_prefix     = "gke-cluster"
  region             = "europe-west2-a"
  google_project     = "${var.google_project_id}"
  kubernetes_version = "${var.kubernetes_version}"
  node_count         = "${var.node_count}"
  machine_type       = "${local.gke_node}"
}

module "k8s_config_gke_1" {
  providers {
    "kubernetes" = "kubernetes.gke_1"
  }

  source = "k8s"

  # workaround for issue with the kubernetes provider constructing cluster name here rather than passing it from the module
  cluster_link = "gke-cluster-europe-west2-a"
}

module "gke_cluster_2" {
  source = "gke"

  organization       = "0"
  cluster_prefix     = "gke-cluster"
  region             = "europe-west3-a"
  kubernetes_version = "${var.kubernetes_version}"
  google_project     = "${var.google_project_id}"
  node_count         = "${var.node_count}"
  machine_type       = "${local.gke_node}"
}

module "k8s_config_gke_2" {
  providers {
    "kubernetes" = "kubernetes.gke_2"
  }

  source = "k8s"

  # workaround for issue with the kubernetes provider constructing cluster name here rather than passing it from the module
  cluster_link = "gke-cluster-europe-west3-a"
}

module "akamai_config" {
  source                = "akamai"
  cluster_ips           = "${local.cluster_ips}"
  aks_cluster_1_enabled = "${var.aks_cluster_1_enabled}"
  aks_cluster_2_enabled = "${var.aks_cluster_2_enabled}"
  gke_cluster_1_enabled = "${var.gke_cluster_1_enabled}"
  gke_cluster_2_enabled = "${var.gke_cluster_2_enabled}"
}

module "gcr" {
  source = "gcr"

  google_project_id = "${var.google_project_id}"
}
