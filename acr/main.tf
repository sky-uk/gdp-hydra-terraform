resource "random_string" "name" {
  keepers = {
    # Generate a new id each time we switch to a new resource group
    group_name = "${var.resource_group_name}"
  }

  length  = 8
  upper   = false
  special = false
  number  = false
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"

  tags = "${var.tags}"
}

resource "azurerm_container_registry" "deploy" {
  name = "${var.project_name}acr${random_string.name.result}"

  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  admin_enabled = true
  sku           = "Standard"

  tags = "${var.tags}"
}

resource "azurerm_azuread_application" "acr_application" {
  name                       = "${var.project_name}-ci-user"
  homepage                   = "http://${var.project_name}-ci"
  identifier_uris            = ["http://${var.project_name}-ci"]
  reply_urls                 = ["http://${var.project_name}-ci"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}

resource "azurerm_azuread_service_principal" "acr_service_principal" {
  application_id = "${azurerm_azuread_application.acr_application.application_id}"
}

resource "random_string" "acr_password" {
  length  = 16
  special = true

  keepers = {
    service_principal = "${azurerm_azuread_service_principal.acr_service_principal.id}"
  }
}

resource "azurerm_azuread_service_principal_password" "acr_service_principal_password" {
  service_principal_id = "${azurerm_azuread_service_principal.acr_service_principal.id}"
  value                = "${random_string.acr_password.result}"
  end_date             = "${timeadd(timestamp(), "8760h")}"

  # This is a hack to stop it generating a new password each time by having a sliding date
  # to get the date to change here you would have to manually taint this resource...
  lifecycle {
    ignore_changes = ["end_date"]
  }
}

resource "azurerm_role_assignment" "acr_service_principal_role" {
  scope                = "${azurerm_container_registry.deploy.id}"
  role_definition_name = "Contributor"
  principal_id         = "${azurerm_azuread_service_principal.acr_service_principal.id}"
}
