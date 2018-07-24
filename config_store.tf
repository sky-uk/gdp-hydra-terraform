data "archive_file" "kubeconfig" {
  type        = "zip"
  output_path = "${path.module}/kubeconfig.zip"

  source {
    content  = "${module.aks_cluster_1.kubeconfig}"
    filename = "kubeconfig_1"
  }

  source {
    content  = "${module.aks_cluster_2.kubeconfig}"
    filename = "kubeconfig_2"
  }

  source {
    content  = "${module.gke_cluster_1.kubeconfig}"
    filename = "kubeconfig_3"
  }

  source {
    content  = "${module.gke_cluster_2.kubeconfig}"
    filename = "kubeconfig_4"
  }
}

resource "azurerm_resource_group" "config_rg" {
  name     = "${local.resource_group_name_config}"
  location = "${var.azure_resource_locations[0]}"
}

resource "azurerm_storage_account" "config_storage" {
  name                     = "${var.project_name}config"
  resource_group_name      = "${azurerm_resource_group.config_rg.name}"
  location                 = "${var.azure_resource_locations[0]}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "config_container" {
  name                  = "config"
  resource_group_name   = "${azurerm_resource_group.config_rg.name}"
  storage_account_name  = "${azurerm_storage_account.config_storage.name}"
  container_access_type = "private"
}

resource "azurerm_storage_blob" "kubeconfig" {
  name = "kubeconfig.zip"

  resource_group_name    = "${azurerm_resource_group.config_rg.name}"
  storage_account_name   = "${azurerm_storage_account.config_storage.name}"
  storage_container_name = "${azurerm_storage_container.config_container.name}"

  type   = "block"
  source = "${data.archive_file.kubeconfig.output_path}"
}
