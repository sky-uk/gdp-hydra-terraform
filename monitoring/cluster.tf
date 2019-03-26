variable "azure_node_ssh_key" {
  description = "SSH key for nodes created in AKS. This SSH key is used as the access key for each of the nodes created in AKS. Keep this safe as it will allow you to remote onto nodes should you need to. You can create a new key with `ssh-keygen -f ./id_rsa -N '' -C aks-key`"
}

variable "azure_client_id" {}
variable "azure_client_secret" {}

variable "node_sku" {}

variable "azure_resource_location" {}

data "kubernetes_service" "ingress" {
  metadata {
    name      = "traefik-ingress-controller"
    namespace = "kube-system"
  }

  depends_on = ["null_resource.cluster"]
}

variable "cluster_prefix" {}

variable "google_project" {}
variable "kubernetes_version" {}

variable "machine_type" {}

variable "node_count" {
  default = 2
}
