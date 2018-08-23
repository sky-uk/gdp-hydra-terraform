provider "azurerm" {
  client_id       = "${var.azure_client_id}"
  client_secret   = "${var.azure_client_secret}"
  subscription_id = "${var.azure_subscription_id}"
  tenant_id       = "${var.azure_tenant_id}"
}

// Configure the Google Cloud provider
provider "google" {
  credentials = "${base64decode(var.google_creds_base64)}"
}

provider "akamai" {
  host          = "${var.akamai_host}"
  access_token  = "${var.akamai_access_token}"
  client_token  = "${var.akamai_client_token}"
  client_secret = "${var.akamai_client_secret}"
}

provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}

module "acr" {
  source       = "acr"
  project_name = "${var.project_name}"
  tags         = "${local.tags}"

  resource_group_name     = "${local.resource_group_name_acr}"
  resource_group_location = "${var.azure_resource_locations[0]}"
}

module "aks_cluster_1" {
  source = "aks"

  project_name = "${var.project_name}"
  tags         = "${local.tags}"

  cluster_prefix            = "${local.resource_group_name_clusters}"
  linux_admin_username      = "aks"
  linux_admin_ssh_publickey = "${var.azure_node_ssh_key}"
  client_id                 = "${var.azure_client_id}"
  client_secret             = "${var.azure_client_secret}"
  kubernetes_version        = "${var.kubernetes_version}"
  node_count                = "${var.node_count}"
  node_sku                  = "${local.aks_node}"

  region = "${var.azure_resource_locations[0]}"
}

module "aks_cluster_2" {
  source = "aks"

  project_name = "${var.project_name}"
  tags         = "${local.tags}"

  cluster_prefix            = "${local.resource_group_name_clusters}"
  linux_admin_username      = "aks"
  linux_admin_ssh_publickey = "${var.azure_node_ssh_key}"
  client_id                 = "${var.azure_client_id}"
  client_secret             = "${var.azure_client_secret}"
  kubernetes_version        = "${var.kubernetes_version}"
  node_count                = "${var.node_count}"
  node_sku                  = "${local.aks_node}"

  region = "${var.azure_resource_locations[1]}"
}

module "gke_cluster_1" {
  source = "gke"

  project_name = "${var.project_name}"
  tags         = "${local.tags}"

  cluster_prefix     = "${local.resource_group_name_clusters}"
  region             = "europe-west2-a"
  google_project     = "${var.google_project_id}"
  kubernetes_version = "${var.kubernetes_version}"
  node_count         = "${var.node_count}"
  machine_type       = "${local.gke_node}"
}

module "gke_cluster_2" {
  source = "gke"

  project_name = "${var.project_name}"
  tags         = "${local.tags}"

  cluster_prefix     = "${local.resource_group_name_clusters}"
  region             = "europe-west3-a"
  kubernetes_version = "${var.kubernetes_version}"
  google_project     = "${var.google_project_id}"
  node_count         = "${var.node_count}"
  machine_type       = "${local.gke_node}"
}

module "k8s_config_aks_1" {
  source = "k8s"

  cluster_name = "aks_1"

  monitoring_endpoint_password = "${var.monitoring_endpoint_password}"

  enable_image_pull_secret = true
  image_pull_server        = "${module.acr.url}"
  image_pull_username      = "${module.acr.username}"
  image_pull_password      = "${module.acr.password}"

  cluster_client_certificate = "${base64decode(module.aks_cluster_1.cluster_client_certificate)}"
  cluster_client_key         = "${base64decode(module.aks_cluster_1.cluster_client_key)}"
  cluster_ca_certificate     = "${base64decode(module.aks_cluster_1.cluster_ca)}"
  host                       = "${module.aks_cluster_1.host}"
}

module "k8s_config_aks_2" {
  source = "k8s"

  cluster_name = "aks_2"

  monitoring_endpoint_password = "${var.monitoring_endpoint_password}"

  enable_image_pull_secret = true
  image_pull_server        = "${module.acr.url}"
  image_pull_username      = "${module.acr.username}"
  image_pull_password      = "${module.acr.password}"

  cluster_client_certificate = "${base64decode(module.aks_cluster_2.cluster_client_certificate)}"
  cluster_client_key         = "${base64decode(module.aks_cluster_2.cluster_client_key)}"
  cluster_ca_certificate     = "${base64decode(module.aks_cluster_2.cluster_ca)}"
  host                       = "${module.aks_cluster_2.host}"
}

module "k8s_config_gke_1" {
  source = "k8s"

  cluster_name = "gke_1"

  monitoring_endpoint_password = "${var.monitoring_endpoint_password}"

  cluster_client_certificate = "${base64decode(module.gke_cluster_1.cluster_client_certificate)}"
  cluster_client_key         = "${base64decode(module.gke_cluster_1.cluster_client_key)}"
  cluster_ca_certificate     = "${base64decode(module.gke_cluster_1.cluster_ca)}"
  host                       = "${module.gke_cluster_1.host}"
}

module "k8s_config_gke_2" {
  source = "k8s"

  cluster_name = "gke_2"

  monitoring_endpoint_password = "${var.monitoring_endpoint_password}"

  cluster_client_certificate = "${base64decode(module.gke_cluster_2.cluster_client_certificate)}"
  cluster_client_key         = "${base64decode(module.gke_cluster_2.cluster_client_key)}"
  cluster_ca_certificate     = "${base64decode(module.gke_cluster_2.cluster_ca)}"
  host                       = "${module.gke_cluster_2.host}"
}

module "akamai_config" {
  source  = "akamai"
  enabled = "${var.akamai_enabled}"

  monitoring_endpoint_password = "${var.monitoring_endpoint_password}"

  cluster_ips = "${local.cluster_ips}"
  zone        = "${var.edge_dns_zone}"
  dns_name    = "${var.edge_dns_name}"

  aks_cluster_1_enabled = "${var.traffic_manager_aks_cluster_1_enabled}"
  aks_cluster_2_enabled = "${var.traffic_manager_aks_cluster_2_enabled}"
  gke_cluster_1_enabled = "${var.traffic_manager_gke_cluster_1_enabled}"
  gke_cluster_2_enabled = "${var.traffic_manager_gke_cluster_2_enabled}"
}

module "cloudflare" {
  source  = "cloudflare"
  enabled = "${var.cloudflare_enabled}"

  monitoring_endpoint_password = "${var.monitoring_endpoint_password}"

  cluster_ips = "${local.cluster_ips}"
  zone        = "${var.edge_dns_zone}"
  dns_name    = "${var.edge_dns_name}"

  aks_cluster_1_enabled = "${var.traffic_manager_aks_cluster_1_enabled}"
  aks_cluster_2_enabled = "${var.traffic_manager_aks_cluster_2_enabled}"
  gke_cluster_1_enabled = "${var.traffic_manager_gke_cluster_1_enabled}"
  gke_cluster_2_enabled = "${var.traffic_manager_gke_cluster_2_enabled}"
}

module "gcr" {
  source = "gcr"

  google_project_id = "${var.google_project_id}"
}
