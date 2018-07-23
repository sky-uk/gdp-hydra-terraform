variable "cluster_ips" {
  type = "map"
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
