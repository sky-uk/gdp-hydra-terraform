output "username" {
  type        = "string"
  description = "Username for the Azure Container Service"
  value       = "${azurerm_azuread_service_principal.acr_service_principal.id}"
}

output "password" {
  type        = "string"
  description = "Password for the Azure Container Service"
  value       = "${azurerm_azuread_service_principal_password.acr_service_principal_password.value}"
  sensitive   = true
}

output "url" {
  type        = "string"
  description = "Docker login URL for Azure Container Service"
  value       = "${azurerm_container_registry.deploy.login_server}"
}
