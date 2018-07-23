variable "resource_group_name" {
  default = "hydra-clusters"
}

variable "kubernetes_version" {
  description = "The version of k8s to use for deployment"
}

variable "node_count" {
  default = 1
}

variable "node_sku" {
  default = "Standard_DS2_v2"
}

variable "region" {
  description = "The regions in which to deploy a AKS cluster"
}

variable "client_id" {
  type        = "string"
  description = "Client ID"
}

variable "client_secret" {
  type        = "string"
  description = "Client secret."
}

variable "cluster_prefix" {
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

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}"
  location = "westeurope"
}

resource "random_string" "cluster_name" {
  keepers = {
    # Generate a new id each time we switch to a new resource group
    group_name = "${var.resource_group_name}"
  }

  length  = 8
  upper   = false
  special = false
  number  = false
}

resource "azurerm_kubernetes_cluster" "aks" {
  name       = "${var.cluster_prefix}-${var.region}"
  dns_prefix = "${random_string.cluster_name.result}"

  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  kubernetes_version  = "${var.kubernetes_version}"

  linux_profile {
    admin_username = "${var.linux_admin_username}"

    ssh_key {
      key_data = "${var.linux_admin_ssh_publickey}"
    }
  }

  agent_pool_profile {
    name    = "agentpool"
    count   = "${var.node_count}"
    vm_size = "${var.node_sku}"
    os_type = "Linux"
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }

  tags {
    source = "terraform"
  }
}

output "kubeconfig" {
  value     = "${azurerm_kubernetes_cluster.aks.kube_config_raw}"
  sensitive = true
}

output "cluster_client_certificate" {
  value     = "${azurerm_kubernetes_cluster.aks.0.kube_config.0.client_certificate}"
  sensitive = true
}

output "cluster_client_key" {
  value     = "${azurerm_kubernetes_cluster.aks.0.kube_config.0.client_key}"
  sensitive = true
}

output "cluster_ca" {
  value     = "${azurerm_kubernetes_cluster.aks.0.kube_config.0.cluster_ca_certificate}"
  sensitive = true
}

output "host" {
  value = "${azurerm_kubernetes_cluster.aks.0.kube_config.0.host}"
}

output "name" {
  value = "${azurerm_kubernetes_cluster.aks.name}"
}
