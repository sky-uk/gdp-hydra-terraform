variable "cluster_ca_certificate" {}
variable "host" {}
variable "cluster_name" {}
variable "monitoring_endpoint_password" {}

variable "prom_metrics_credentials" {
  type = "map"
}

variable "node_count" {}

variable "config_path" {
  default = ""
}
