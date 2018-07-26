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
