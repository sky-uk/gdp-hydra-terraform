output "username" {
  value = "${azurerm_azuread_service_principal.acr_service_principal.id}"
}

output "password" {
  value     = "${azurerm_azuread_service_principal_password.acr_service_principal_password.value}"
  sensitive = true
}

output "url" {
  value = "${azurerm_container_registry.deploy.login_server}"
}
