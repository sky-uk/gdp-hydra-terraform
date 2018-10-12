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
