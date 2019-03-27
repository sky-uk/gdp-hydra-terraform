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

resource "random_string" "prom_metrics_password" {
  length  = 16
  special = true
}

module "k8s_config_aks_1" {
  source = "k8s"

  cluster_name = "aks_1"

  monitoring_endpoint_password = "${var.monitoring_endpoint_password}"

  host       = "${module.aks_cluster_1.host}"
  node_count = "${var.node_count}"

  prom_metrics_credentials = {
    username = "${var.prom_metrics_username}"
    password = "${random_string.prom_metrics_password.result}"
  }

  kubeconfig_path = "${local.aks1}"
}

module "k8s_config_aks_2" {
  source = "k8s"

  cluster_name = "aks_2"

  monitoring_endpoint_password = "${var.monitoring_endpoint_password}"

  host       = "${module.aks_cluster_2.host}"
  node_count = "${var.node_count}"

  prom_metrics_credentials = {
    username = "${var.prom_metrics_username}"
    password = "${random_string.prom_metrics_password.result}"
  }

  kubeconfig_path = "${local.aks2}"
}

module "k8s_config_gke_1" {
  source = "k8s"

  cluster_name = "gke_1"

  monitoring_endpoint_password = "${var.monitoring_endpoint_password}"

  host       = "${module.gke_cluster_1.host}"
  node_count = "${var.node_count}"

  prom_metrics_credentials = {
    username = "${var.prom_metrics_username}"
    password = "${random_string.prom_metrics_password.result}"
  }

  kubeconfig_path = "${local.gke1}"
}

module "k8s_config_gke_2" {
  source = "k8s"

  cluster_name = "gke_2"

  monitoring_endpoint_password = "${var.monitoring_endpoint_password}"

  host       = "${module.gke_cluster_2.host}"
  node_count = "${var.node_count}"

  prom_metrics_credentials = {
    username = "${var.prom_metrics_username}"
    password = "${random_string.prom_metrics_password.result}"
  }

  kubeconfig_path = "${local.gke2}"
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

module "monitoring_k8s" {
  source = "k8smonitoring"

  kubeconfig_path = "${local.monitoring}"

  cluster_prefix = "${var.project_name}-monitoring"
}

module "monitoring_config" {
  source = "monitoring"

  kubeconfig_path = "${local.monitoring}"

  project_name = "${var.project_name}"
  tags         = "${local.tags}"

  cluster_ips = "${local.cluster_ips}"

  cluster_prefix = "${var.project_name}-monitoring"

  prometheus_scrape_credentials = {
    username = "${var.prom_metrics_username}"
    password = "${random_string.prom_metrics_password.result}"
  }

  prometheus_ui_password = "${var.prometheus_ui_password}"
  cluster_issuer_email   = "${var.cluster_issuer_email}"
  monitoring_dns_name    = "${module.akamai_config.monitoring_dns_name}"

  logging_namespace      = "${module.monitoring_k8s.logging_namespace}"
  monitoring_namespace   = "${module.monitoring_k8s.monitoring_namespace}"
  tiller_service_account = "${module.monitoring_k8s.tiller_service_account_name}"
}
