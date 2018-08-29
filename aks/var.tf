variable "project_name" {
  type        = "string"
  description = "The name of the hydra project"
}

variable "kubernetes_version" {
  type        = "string"
  description = "The version of k8s to use for deployment"
}

variable "node_count" {
  type        = "string"
  description = "The number of nodes that should be provisioned in the cluster"
  default     = 1
}

variable "node_sku" {
  type        = "string"
  description = "The size of machine to be used for each of the nodes in the cluster"
  default     = "Standard_DS2_v2"
}

variable "region" {
  description = "The Azure Region to provision the cluster into"
  type        = "string"
}

variable "client_id" {
  description = "The client_id for the Azure service principal to be used for the cluster"
  type        = "string"
}

variable "client_secret" {
  type        = "string"
  description = "The client_secret for the Azure service principal to be used for the cluster"
}

variable "cluster_prefix" {
  type        = "string"
  description = "The cluster name prefix. This will be joined with the index of the cluster eg. cluster_prefix_1, cluster_prefix_2"
}

variable "linux_admin_username" {
  type        = "string"
  description = "User name for authentication to the Kubernetes linux agent virtual machines in the cluster."
}

variable "linux_admin_ssh_publickey" {
  type        = "string"
  description = "Configure all the linux virtual machines in the cluster with the SSH RSA public key string. The key should include three parts, for example 'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm'"
}

variable "tags" {
  type        = "map"
  description = "Tags to apply to all resources"
}
