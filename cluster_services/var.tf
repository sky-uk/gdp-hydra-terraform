variable "client_certificate" {
  default = ""
}

variable "client_key" {
  default = ""
}

variable "cluster_ca_certificate" {}
variable "host" {}
variable "enable_traefik" {}
variable "cluster_name" {}
variable "traefik_replica_count" {}
variable "cluster_issuer_email" {}
variable "tiller_service_account" {}
variable "kubeconfig" {}
