module "monitoring_cluster" {
  source = "../aks"

  project_name = "${var.project_name}"
  tags         = "${var.tags}"

  cluster_prefix            = "${var.project_name}-monitoring"
  linux_admin_username      = "aks"
  linux_admin_ssh_publickey = "${var.azure_node_ssh_key}"
  client_id                 = "${var.azure_client_id}"
  client_secret             = "${var.azure_client_secret}"
  kubernetes_version        = "${var.kubernetes_version}"
  node_count                = "${var.node_count}"
  node_sku                  = "${var.node_sku}"

  region = "${var.azure_resource_location}"
}

variable "azure_node_ssh_key" {
  description = "SSH key for nodes created in AKS. This SSH key is used as the access key for each of the nodes created in AKS. Keep this safe as it will allow you to remote onto nodes should you need to. You can create a new key with `ssh-keygen -f ./id_rsa -N '' -C aks-key`"
}

variable "azure_client_id" {}
variable "azure_client_secret" {}

variable "kubernetes_version" {}

variable "node_sku" {}

variable "node_count" {
  default = 2
}

variable "azure_resource_location" {}
