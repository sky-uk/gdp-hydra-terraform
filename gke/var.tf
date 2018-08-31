variable "project_name" {
  type        = "string"
  description = "The name of the hydra project"
}

variable "kubernetes_version" {
  type        = "string"
  description = "The version of kubernetes to use for deployment"
}

variable "google_project" {
  type        = "string"
  description = "The google project in which to deploy the cluster"
}

variable "cluster_prefix" {
  type        = "string"
  description = "The cluster name prefix. This will be joined with the index of the cluster eg. cluster_prefix_1, cluster_prefix_2"
}

variable "node_count" {
  type        = "string"
  description = "The number of nodes to create within the cluster"
  default     = 1
}

variable "machine_type" {
  type        = "string"
  description = "The machine type to use for creating the cluster nodes"
  default     = "n1-standard-1"
}

variable "region" {
  type        = "string"
  description = "The region in which to deploy a GKE cluster"
}

variable "tags" {
  type        = "map"
  description = "Tags to apply to all resources"
}
