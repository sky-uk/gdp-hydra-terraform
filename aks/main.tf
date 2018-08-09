locals {
  cluster_name = "${var.cluster_prefix}-${var.region}"
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

module "service_principal" {
  source = "service_principal"

  sp_name = "${local.cluster_name}"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name       = "${local.cluster_name}"
  dns_prefix = "${random_string.cluster_name.result}"

  location            = "${var.region}"
  resource_group_name = "${var.resource_group_name}"
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
    client_id     = "${module.service_principal.application_id}"
    client_secret = "${module.service_principal.sp_password}"
  }

  tags {
    source = "terraform"
  }
}
