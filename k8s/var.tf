variable "cluster_client_certificate" {
  default = ""
}

variable "cluster_client_key" {
  default = ""
}

variable "cluster_ca_certificate" {}
variable "host" {}
variable "cluster_name" {}
variable "monitoring_endpoint_password" {}

variable "prom_metrics_credentials" {
  type = "map"
}

variable "node_count" {}

varible "config_path" {
  default = ""
}
