locals {
  resource_group_name_clusters = "${module.hydra.project_name}-clusters"

  resource_group_name_config = "${module.hydra.project_name}-config"

  node_match = {
    "small"   = "n1-standard-2,Standard_D2_v3"
    "small_m" = "n1-highmem-2,Standard_A2m_v2"
    "medium"  = "n1-standard-4,Standard_D4_v3"
    "large"   = "n1-standard-16,Standard_D16_v3"
  }

  gke_node = "${element(split(",",local.node_match[module.hydra.node_type]), 0)}"
  aks_node = "${element(split(",",local.node_match[module.hydra.node_type]), 1)}"

  cluster_ips = {
    "aks_cluster_1" = "${module.k8s_config_aks_1.cluster_ingress_ip}"
    "aks_cluster_2" = "${module.k8s_config_aks_2.cluster_ingress_ip}"
    "gke_cluster_1" = "${module.k8s_config_gke_1.cluster_ingress_ip}"
    "gke_cluster_2" = "${module.k8s_config_gke_2.cluster_ingress_ip}"
  }

  tags = {
    # need to use underscores here as GCP doesnt accept full stops
    "hydra_version" = "0_0_4"
    "hydra_project" = "${module.hydra.project_name}"
  }

  gke1       = "${path.cwd}/gke1.kubeconfig"
  gke2       = "${path.cwd}/gke2.kubeconfig"
  monitoring = "${path.cwd}/monitoring.kubeconfig"
  aks1       = "${path.cwd}/aks1.kubeconfig"
  aks2       = "${path.cwd}/aks2.kubeconfig"
}

module "hydra" {
  source = "../"
}

provider "azurerm" {
  client_id       = "${module.hydra.azure_client_id}"
  client_secret   = "${module.hydra.azure_client_secret}"
  subscription_id = "${module.hydra.azure_subscription_id}"
  tenant_id       = "${module.hydra.azure_tenant_id}"
}

// Configure the Google Cloud provider
provider "google" {
  credentials = "${base64decode(module.hydra.google_creds_base64)}"
}

provider "azuread" {
  client_id       = "${module.hydra.azure_client_id}"
  client_secret   = "${module.hydra.azure_client_secret}"
  subscription_id = "${module.hydra.azure_subscription_id}"
  tenant_id       = "${module.hydra.azure_tenant_id}"
}

module "aks_cluster_1" {
  source = "aks"

  project_name = "${module.hydra.project_name}"
  tags         = "${local.tags}"

  cluster_prefix            = "${local.resource_group_name_clusters}"
  linux_admin_username      = "aks"
  linux_admin_ssh_publickey = "${module.hydra.azure_node_ssh_key}"
  client_id                 = "${module.hydra.azure_client_id}"
  client_secret             = "${module.hydra.azure_client_secret}"
  kubernetes_version        = "${module.hydra.kubernetes_version}"
  node_count                = "${module.hydra.node_count}"
  node_sku                  = "${local.aks_node}"

  region = "${module.hydra.azure_resource_locations[0]}"

  kubeconfig_path = "${local.aks1}"
}

module "aks_cluster_2" {
  source = "aks"

  project_name = "${module.hydra.project_name}"
  tags         = "${local.tags}"

  cluster_prefix            = "${local.resource_group_name_clusters}"
  linux_admin_username      = "aks"
  linux_admin_ssh_publickey = "${module.hydra.azure_node_ssh_key}"
  client_id                 = "${module.hydra.azure_client_id}"
  client_secret             = "${module.hydra.azure_client_secret}"
  kubernetes_version        = "${module.hydra.kubernetes_version}"
  node_count                = "${module.hydra.node_count}"
  node_sku                  = "${local.aks_node}"

  region = "${module.hydra.azure_resource_locations[1]}"

  kubeconfig_path = "${local.aks2}"
}

module "gke_cluster_1" {
  source = "gke"

  project_name = "${module.hydra.project_name}"
  tags         = "${local.tags}"

  cluster_prefix     = "${local.resource_group_name_clusters}"
  region             = "europe-west2-a"
  google_project     = "${module.hydra.google_project_id}"
  kubernetes_version = "${module.hydra.kubernetes_version}"
  node_count         = "${module.hydra.node_count}"
  machine_type       = "${local.gke_node}"

  kubeconfig_path = "${local.gke1}"
}

module "gke_cluster_2" {
  source = "gke"

  project_name = "${module.hydra.project_name}"
  tags         = "${local.tags}"

  cluster_prefix     = "${local.resource_group_name_clusters}"
  region             = "europe-west3-a"
  kubernetes_version = "${module.hydra.kubernetes_version}"
  google_project     = "${module.hydra.google_project_id}"
  node_count         = "${module.hydra.node_count}"
  machine_type       = "${local.gke_node}"
  kubeconfig_path    = "${local.gke2}"
}

module "monitoring_cluster" {
  source = "gke"

  project_name = "${module.hydra.project_name}"
  tags         = "${local.tags}"

  cluster_prefix     = "${module.hydra.project_name}-monitoring"
  region             = "europe-west2-a"
  google_project     = "${module.hydra.google_project_id}"
  kubernetes_version = "${module.hydra.kubernetes_version}"
  node_count         = "${module.hydra.node_count}"
  machine_type       = "${local.gke_node}"

  kubeconfig_path = "${local.monitoring}"
}
