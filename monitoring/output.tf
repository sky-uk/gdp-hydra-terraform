output "prometheus_url" {
  value = "${azurerm_container_group.monitoring.fqdn}:9090"
}

output "grafana_url" {
  value = "${azurerm_container_group.monitoring.fqdn}:3000"
}