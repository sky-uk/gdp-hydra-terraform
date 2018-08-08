variable "sp_name" {}

resource "azurerm_azuread_application" "aks_app" {
  name = "${var.sp_name}"
}

resource "azurerm_azuread_service_principal" "aks_sp" {
  application_id = "${azurerm_azuread_application.aks_app.application_id}"
}

resource "random_string" "aks_sp_password" {
  length  = 16
  special = true

  keepers = {
    service_principal = "${azurerm_azuread_service_principal.aks_sp.id}"
  }
}

resource "azurerm_azuread_service_principal_password" "aks_sp_password" {
  service_principal_id = "${azurerm_azuread_service_principal.aks_sp.id}"
  value                = "${random_string.aks_sp_password.result}"
  end_date             = "${timeadd(timestamp(), "8760h")}"

  # This stops be 'end_date' changing on each run and causing a new password to be set
  # to get the date to change here you would have to manually taint this resource...
  lifecycle {
    ignore_changes = ["end_date"]
  }
}

output "client_id" {
  value = "${azurerm_azuread_service_principal.aks_sp.id}"
}

output "client_secret" {
  sensitive = true
  value     = "${random_string.aks_sp_password.result}"
}
