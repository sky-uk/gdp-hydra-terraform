variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "azure_tenant_id" {}
variable "azure_subscription_id" {}

variable "azure_resource_locations" {
  description = "List of locations used for deploying resources. The first location is the default location that any tooling such as the docker registry will be created in. Only two values are required, others will be ignored. They should be valid Azure region strings. Defaults to westeurope and northeurope. "

  default = [
    "westeurope",
    "northeurope",
  ]
}

variable "project_name" {
  description = "Name of the project that is used across the deployment for naming resources. This will be used in cluster names, DNS entries and all other configuration and will enable you to identify resources."
}

variable "azure_node_ssh_key" {
  description = "SSH key for nodes created in AKS. This SSH key is used as the access key for each of the nodes created in AKS. Keep this safe as it will allow you to remote onto nodes should you need to. You can create a new key with `ssh-keygen -f ./id_rsa -N '' -C aks-key`"
}

variable "google_project_id" {}

variable "google_creds_base64" {
  description = "The service account json file base64 encoded"
}

variable "edge_dns_zone" {
  description = "The dns zone the edge should use eg. example.com"
}

variable "edge_dns_name" {
  description = "The dns name the edge should use (akamai or cloudflare) eg. hydraclusters is combined with zone to create hydraclusters.example.com"
}

variable "akamai_host" {
  description = "Host for akamai API"
}

variable "akamai_enabled" {}

variable "akamai_client_secret" {}

variable "akamai_access_token" {}

variable "akamai_client_token" {}

variable "cloudflare_email" {}
variable "cloudflare_token" {}
variable "cloudflare_enabled" {}

variable "monitoring_endpoint_password" {
  default = "eafc7df7-6ed0-4e35-b65c-76bb14748a7b"
}


variable "kubernetes_version" {
  description = "The version of kubernetes to deploy. You should ensure that this version is available in each region. Changing this property will result in an upgrade of clusters. Defaults to 1.10.5"
  default     = "1.10.5"
}

variable "node_type" {
  description = "Size of nodes to provision in each cluster, options are small, medium, large. Defaults to small. Changing this will result in a full rebuild of all clusters."
  default     = "small"
}

variable "traffic_manager_aks_cluster_1_enabled" {
  default = true
}

variable "traffic_manager_aks_cluster_2_enabled" {
  default = true
}

variable "traffic_manager_gke_cluster_1_enabled" {
  default = true
}

variable "traffic_manager_gke_cluster_2_enabled" {
  default = true
}

variable "enable_traefik" {
  default = true
}

variable "enable_prometheus" {
  default = true
}

locals {
  resource_group_name_clusters = "${var.project_name}-clusters"

  resource_group_name_acr = "${var.project_name}-acr"

  resource_group_name_config = "${var.project_name}-config"

  node_match = {
    "small"  = "n1-standard-2,Standard_D2_v3"
    "medium" = "n1-standard-4,Standard_D4_v3"
    "large"  = "n1-standard-16,Standard_D16_v3"
  }

  gke_node = "${element(split(",",local.node_match[var.node_type]), 0)}"
  aks_node = "${element(split(",",local.node_match[var.node_type]), 1)}"

  cluster_ips = {
    # "aks_cluster_1" = "${module.k8s_config_aks_1.cluster_ingress_ip}"
    "aks_cluster_1" = "52.138.252.107"
    "aks_cluster_2" = "${module.k8s_config_aks_2.cluster_ingress_ip}"
    "gke_cluster_1" = "${module.k8s_config_gke_1.cluster_ingress_ip}"
    "gke_cluster_2" = "${module.k8s_config_gke_2.cluster_ingress_ip}"
  }
}

variable "node_count" {
  description = "Number of nodes in each cluster."
  default     = 1
}
