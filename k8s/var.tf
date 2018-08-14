variable "image_pull_server" {
  default = ""
}

variable "image_pull_username" {
  default = ""
}

variable "image_pull_password" {
  default = ""
}

variable "enable_image_pull_secret" {
  default = 0
}

variable "cluster_client_certificate" {}
variable "cluster_client_key" {}
variable "cluster_ca_certificate" {}
variable "host" {}
variable "monitoring_endpoint_password" {}

