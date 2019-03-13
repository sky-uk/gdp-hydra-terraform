variable project_name {}
variable google_project_id {}
variable google_creds_base64 {}
variable azure_client_id {}
variable azure_client_secret {}
variable azure_tenant_id {}
variable azure_subscription_id {}
variable edge_dns_zone {}
variable edge_dns_name {}
variable kubernetes_version {}
variable azure_node_ssh_key {}
variable prometheus_ui_password {}
variable cluster_issuer_email {}
variable akamai_access_token {}
variable akamai_client_token {}
variable akamai_host {}
variable akamai_client_secret {}

# generate passowrd for monitoring endpoint
resource "random_string" "monitoring_password" {
  length  = 16
  special = true
}

module "hydra" {
  "source" = ".."

  "project_name"          = "${var.project_name}"
  "azure_client_id"       = "${var.azure_client_id}"
  "azure_client_secret"   = "${var.azure_client_secret}"
  "azure_tenant_id"       = "${var.azure_tenant_id}"
  "azure_subscription_id" = "${var.azure_subscription_id}"
  "azure_node_ssh_key"    = "${var.azure_node_ssh_key}"
  "google_project_id"     = "${var.google_project_id}"
  "google_creds_base64"   = "${var.google_creds_base64}"
  "akamai_host"           = "${var.akamai_host}"
  "akamai_client_secret"  = "${var.akamai_client_secret}"
  "akamai_access_token"   = "${var.akamai_access_token}"
  "akamai_client_token"   = "${var.akamai_client_token}"
  "kubernetes_version"    = "${var.kubernetes_version}"

  "node_type"                             = "medium"
  "node_count"                            = 2
  "traffic_manager_aks_cluster_1_enabled" = true
  "traffic_manager_aks_cluster_2_enabled" = true
  "traffic_manager_gke_cluster_1_enabled" = true
  "traffic_manager_gke_cluster_2_enabled" = true

  "akamai_enabled"               = true
  "edge_dns_zone"                = "${var.edge_dns_zone}"
  "edge_dns_name"                = "${var.edge_dns_name}"
  "monitoring_endpoint_password" = "${random_string.monitoring_password.result}"

  cloudflare_enabled = false
  cloudflare_email   = "empty"
  cloudflare_token   = "empty"

  prometheus_ui_password = "${var.prometheus_ui_password}"
  cluster_issuer_email   = "${var.cluster_issuer_email}"
}

output "ips" {
  value = "${module.hydra.ips}"
}

output "kubeconfig_url" {
  value = "${module.hydra.kubeconfig_url}"
}
