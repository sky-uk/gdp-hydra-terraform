variable "cluster_ips" {
  description = "Map of the IP addresses to the ingress of all clusters in the hydra deployment"
  type        = "map"
}

variable "enabled" {}

variable "zone" {}
variable "dns_name" {}

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
