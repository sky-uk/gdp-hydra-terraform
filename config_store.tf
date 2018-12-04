data "archive_file" "kubeconfig" {
  type        = "zip"
  output_path = "kubeconfig.zip"

  source {
    content  = "${module.aks_cluster_1.kubeconfig}"
    filename = "kubeconfig_aks_1"
  }

  source {
    content  = "${module.aks_cluster_2.kubeconfig}"
    filename = "kubeconfig_aks_2"
  }

  source {
    content  = "${module.gke_cluster_1.kubeconfig}"
    filename = "kubeconfig_gke_1"
  }

  source {
    content  = "${module.gke_cluster_2.kubeconfig}"
    filename = "kubeconfig_gke_2"
  }
}

resource "azurerm_resource_group" "config_rg" {
  name     = "${local.resource_group_name_config}"
  location = "${var.azure_resource_locations[0]}"

  tags = "${local.tags}"
}

resource "azurerm_storage_account" "config_storage" {
  name                     = "${var.project_name}config"
  resource_group_name      = "${azurerm_resource_group.config_rg.name}"
  location                 = "${var.azure_resource_locations[0]}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = "${local.tags}"
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

data "azurerm_storage_account_sas" "config_container_sas" {
  connection_string = "${azurerm_storage_account.config_storage.primary_connection_string}"
  https_only        = true

  resource_types {
    service   = false
    container = false
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "${timestamp()}"
  expiry = "${timeadd(timestamp(), "8760h")}"

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
  }
}
