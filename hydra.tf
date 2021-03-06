# This module provisions/configs the following:
#
# - AKS and GKE clusters
# - CDN GTM
# - K8S config to the 4 clusters (minus monitoring)
# - Monitoring cluster

provider "azurerm" {
  client_id       = "${var.azure_client_id}"
  client_secret   = "${var.azure_client_secret}"
  subscription_id = "${var.azure_subscription_id}"
  tenant_id       = "${var.azure_tenant_id}"
}

// Configure the Google Cloud provider
provider "google" {
  scopes = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    "https://www.googleapis.com/auth/devstorage.full_control",
    "https://www.googleapis.com/auth/userinfo.email",
  ]

  credentials = "${base64decode(var.google_creds_base64)}"
}

provider "azuread" {
  client_id       = "${var.azure_client_id}"
  client_secret   = "${var.azure_client_secret}"
  subscription_id = "${var.azure_subscription_id}"
  tenant_id       = "${var.azure_tenant_id}"
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

  kubeconfig_path = "${local.aks1}"
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

  kubeconfig_path = "${local.aks2}"
}

module "gke_cluster_1" {
  source = "gke"

  project_name = "${var.project_name}"
  tags         = "${local.tags}"

  cluster_prefix     = "${local.resource_group_name_clusters}"
  region             = "europe-west2-b"
  google_project     = "${var.google_project_id}"
  kubernetes_version = "${var.kubernetes_version}"
  node_count         = "${var.node_count}"
  machine_type       = "${local.gke_node}"

  kubeconfig_path = "${local.gke1}"
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
  kubeconfig_path    = "${local.gke2}"
}

resource "random_string" "prom_metrics_password" {
  length  = 16
  special = true
}

module "k8s_config_aks_1" {
  source = "k8s"

  cluster_name = "aks_1"

  monitoring_endpoint_password = "${var.monitoring_endpoint_password}"
  monitoring_dns_name          = "${module.akamai_config.monitoring_dns_name}"

  host       = "${module.aks_cluster_1.host}"
  node_count = "${var.node_count}"

  prom_metrics_credentials = {
    username = "${var.prom_metrics_username}"
    password = "${random_string.prom_metrics_password.result}"
  }

  ingress_controller = "${module.cluster_services_aks1.helm_traefik_name}"

  kubeconfig_path            = "${local.aks1}"
  cluster_ca_certificate     = "${module.aks_cluster_1.cluster_ca_certificate}"
  cluster_client_certificate = "${module.aks_cluster_1.cluster_client_certificate}"
  cluster_client_key         = "${module.aks_cluster_1.cluster_client_key}"
  username                   = "${module.aks_cluster_1.username}"
  password                   = "${module.aks_cluster_1.password}"
}

module "k8s_config_aks_2" {
  source = "k8s"

  cluster_name = "aks_2"

  monitoring_endpoint_password = "${var.monitoring_endpoint_password}"
  monitoring_dns_name          = "${module.akamai_config.monitoring_dns_name}"

  host       = "${module.aks_cluster_2.host}"
  node_count = "${var.node_count}"

  prom_metrics_credentials = {
    username = "${var.prom_metrics_username}"
    password = "${random_string.prom_metrics_password.result}"
  }

  ingress_controller = "${module.cluster_services_aks2.helm_traefik_name}"

  kubeconfig_path            = "${local.aks2}"
  cluster_ca_certificate     = "${module.aks_cluster_2.cluster_ca_certificate}"
  cluster_client_certificate = "${module.aks_cluster_2.cluster_client_certificate}"
  cluster_client_key         = "${module.aks_cluster_2.cluster_client_key}"
  username                   = "${module.aks_cluster_2.username}"
  password                   = "${module.aks_cluster_2.password}"
}

module "k8s_config_gke_1" {
  source = "k8s"

  cluster_name = "gke_1"

  monitoring_endpoint_password = "${var.monitoring_endpoint_password}"
  monitoring_dns_name          = "${module.akamai_config.monitoring_dns_name}"

  host       = "${module.gke_cluster_1.host}"
  node_count = "${var.node_count}"

  prom_metrics_credentials = {
    username = "${var.prom_metrics_username}"
    password = "${random_string.prom_metrics_password.result}"
  }

  ingress_controller = "${module.cluster_services_gke1.helm_traefik_name}"

  kubeconfig_path            = "${local.gke1}"
  cluster_ca_certificate     = "${module.gke_cluster_1.cluster_ca_certificate}"
  cluster_client_certificate = "${module.gke_cluster_1.cluster_client_certificate}"
  cluster_client_key         = "${module.gke_cluster_1.cluster_client_key}"
  username                   = "${module.gke_cluster_1.username}"
  password                   = "${module.gke_cluster_1.password}"
}

module "k8s_config_gke_2" {
  source = "k8s"

  cluster_name = "gke_2"

  monitoring_endpoint_password = "${var.monitoring_endpoint_password}"
  monitoring_dns_name          = "${module.akamai_config.monitoring_dns_name}"

  host       = "${module.gke_cluster_2.host}"
  node_count = "${var.node_count}"

  prom_metrics_credentials = {
    username = "${var.prom_metrics_username}"
    password = "${random_string.prom_metrics_password.result}"
  }

  ingress_controller = "${module.cluster_services_gke2.helm_traefik_name}"

  kubeconfig_path            = "${local.gke2}"
  cluster_ca_certificate     = "${module.gke_cluster_2.cluster_ca_certificate}"
  cluster_client_certificate = "${module.gke_cluster_2.cluster_client_certificate}"
  cluster_client_key         = "${module.gke_cluster_2.cluster_client_key}"
  username                   = "${module.gke_cluster_2.username}"
  password                   = "${module.gke_cluster_2.password}"
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

  monitoring_cluster_ips = "${module.monitoring_k8s.ingress_ip}"
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

module "monitoring_cluster" {
  source = "gke"

  project_name = "${var.project_name}"
  tags         = "${local.tags}"

  cluster_prefix     = "${var.project_name}-monitoring"
  region             = "europe-west2-a"
  google_project     = "${var.google_project_id}"
  kubernetes_version = "${var.kubernetes_version}"
  node_count         = "${var.node_count}"
  machine_type       = "${local.gke_node}"

  kubeconfig_path = "${local.monitoring}"
}

module "monitoring_k8s" {
  source = "k8smonitoring"

  kubeconfig_path            = "${local.monitoring}"
  host                       = "${module.monitoring_cluster.host}"
  cluster_ca_certificate     = "${module.monitoring_cluster.cluster_ca_certificate}"
  cluster_client_certificate = "${module.monitoring_cluster.cluster_client_certificate}"
  cluster_client_key         = "${module.monitoring_cluster.cluster_client_key}"
  username                   = "${module.monitoring_cluster.username}"
  password                   = "${module.monitoring_cluster.password}"

  cluster_prefix = "${var.project_name}-monitoring"

  ingress_controller = "${module.cluster_services_monitoring.helm_traefik_name}"
}

module "monitoring_config" {
  source = "monitoring"

  kubeconfig_path            = "${local.monitoring}"
  host                       = "${module.monitoring_cluster.host}"
  cluster_ca_certificate     = "${module.monitoring_cluster.cluster_ca_certificate}"
  cluster_client_certificate = "${module.monitoring_cluster.cluster_client_certificate}"
  cluster_client_key         = "${module.monitoring_cluster.cluster_client_key}"
  username                   = "${module.monitoring_cluster.username}"
  password                   = "${module.monitoring_cluster.password}"

  project_name = "${var.project_name}"
  tags         = "${local.tags}"

  cluster_ips = "${local.cluster_ips}"

  cluster_prefix = "${var.project_name}-monitoring"

  prometheus_scrape_credentials = {
    username = "${var.prom_metrics_username}"
    password = "${random_string.prom_metrics_password.result}"
  }

  letsencrypt_environment = "${var.letsencrypt_environment}"

  prometheus_ui_password = "${var.prometheus_ui_password}"
  cluster_issuer_email   = "${var.cluster_issuer_email}"
  monitoring_dns_name    = "${module.akamai_config.monitoring_dns_name}"

  logging_namespace      = "${module.monitoring_k8s.logging_namespace}"
  monitoring_namespace   = "${module.monitoring_k8s.monitoring_namespace}"
  tiller_service_account = "${module.monitoring_k8s.tiller_service_account_name}"
}
