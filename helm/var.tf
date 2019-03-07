variable "client_certificate" {}
variable "client_key" {}
variable "cluster_ca_certificate" {}
variable "host" {}
variable "enable_traefik" {}
variable "enable_prometheus" {}
variable "cluster_name" {}

variable "monitoring_dns_name" {
  type        = "string"
  description = "DNS name for monitoring cluster ingress"
}

variable "fluentd_ingress_ip" {}

variable "tiller_service_account" {}
