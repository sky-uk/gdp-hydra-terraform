variable "cluster_ips" {
  description = "Map of the IP addresses to the ingress of all clusters in the hydra deployment"
  type        = "map"
}

variable "monitoring_cluster_ips" {
  description = "IP address to the ingress of the monitoring cluster"
  type        = "string"
}

variable "enabled" {}

variable "zone" {}
variable "dns_name" {}
variable "monitoring_endpoint_password" {}

variable "aks_cluster_1_enabled" {
  description = "Enable the cluster in the Akamai traffic manager"
  default     = true
}

variable "aks_cluster_2_enabled" {
  description = "Enable the cluster in the Akamai traffic manager"
  default     = true
}

variable "gke_cluster_1_enabled" {
  description = "Enable the cluster in the Akamai traffic manager"
  default     = true
}

variable "gke_cluster_2_enabled" {
  description = "Enable the cluster in the Akamai traffic manager"
  default     = true
}
