variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "azure_tenant_id" {}
variable "azure_subscription_id" {}

variable "azure_resource_locations" {
  default = [
    "westeurope",
    "northeurope",
  ]
}

variable "project_name" {
  description = "Name of the project that is used across the deployment for naming resources"
}

variable "azure_node_ssh_key" {
  description = "SSH key for nodes created in AKS"
}

variable "gcp_creds_base64" {
  description = "The service account json file base64 encoded"
}

variable "akamai_host" {
  description = "Host for akamai API"
}

variable "akamai_client_secret" {}

variable "akamai_access_token" {}

variable "akamai_client_token" {}

variable "kubernetes_version" {
  default = "1.10.5"
}

variable "google_project_id" {}

variable "node_type" {
  default = "small"
}

variable "aks_cluster_1_enabled" {
  default = true
}

variable "aks_cluster_2_enabled" {
  default = true
}

variable "gke_cluster_1_enabled" {
  default = true
}

variable "gke_cluster_2_enabled" {
  default = true
}

locals {
  resource_group_name_clusters = "${var.project_name}-clusters"

  resource_group_name_acr = "${var.project_name}-acr"

  node_match = {
    "small"  = "n1-standard-2,Standard_D2_v3"
    "medium" = "n1-standard-4,Standard_D4_v3"
    "large"  = "n1-standard-16,Standard_D16_v3"
  }

  gke_node = "${element(split(",",local.node_match[var.node_type]), 0)}"
  aks_node = "${element(split(",",local.node_match[var.node_type]), 1)}"

  cluster_ips = {
    "aks_cluster_1" = "${module.k8s_config_aks_1.cluster_ingress_ip}"
    "aks_cluster_2" = "${module.k8s_config_aks_2.cluster_ingress_ip}"
    "gke_cluster_1" = "${module.k8s_config_gke_1.cluster_ingress_ip}"
    "gke_cluster_2" = "${module.k8s_config_gke_2.cluster_ingress_ip}"
  }
}

variable "node_count" {
  default = 1
}
