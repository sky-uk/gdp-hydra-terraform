variable "project_name" {
  type        = "string"
  description = "The name of the hydra project"
}

variable "tags" {
  type        = "map"
  description = "Tags to apply to all resources"
}

variable "cluster_ips" {
  type        = "map"
  description = "Map of the IP addresses to the ingress of all clusters in the hydra deployment"
}

variable "prometheus_scrape_credentials" {
  type        = "map"
  description = "Credentials for worker prometheus metric endpoints"
}

variable "prometheus_ui_password" {
  type        = "string"
  description = "The password used for logging into the prometheus UI via basic auth. The username is always prom"
}

variable "cluster_issuer_email" {
  type        = "string"
  description = "Email used for the cert manager ClusterIssuer. Should be accessible as it will receive expiration notifications"
}

variable "monitoring_dns_name" {
  type        = "string"
  description = "DNS name for monitoring cluster ingress"
}

variable "config_path" {
  type        = "string"
  description = "Path to the kubeconfig file"
}
