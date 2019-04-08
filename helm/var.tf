variable "enable_traefik" {}
variable "enable_prometheus" {}
variable "cluster_name" {}

variable "monitoring_dns_name" {
  type        = "string"
  description = "DNS name for monitoring cluster ingress"
}

variable "monitoring_endpoint_password" {}
variable "fluentd_ingress_ip" {}

variable "tiller_service_account" {}
variable "monitoring_namespace" {}
variable "logging_namespace" {}
variable "kubeconfig_path" {}
variable "host" {}
variable "cluster_ca_certificate" {}
variable "cluster_client_certificate" {}
variable "cluster_client_key" {}
variable "username" {}
variable "password" {}
