variable "cluster_client_certificate" {}
variable "cluster_client_key" {}
variable "host" {}
variable "cluster_name" {}
variable "monitoring_endpoint_password" {}

variable "prom_metrics_credentials" {
  type = "map"
}

variable "node_count" {}

variable "kubeconfig_path" {
  type = "map"
}

variable "cluster_ca_certificate" {}
variable "username" {}
variable "password" {}
variable "monitoring_dns_name" {}
