output "kubeconfig" {
  description = "The kubeconfig file that can be used to access the cluster that has been created"
  value       = "${azurerm_kubernetes_cluster.aks.kube_config_raw}"
  sensitive   = true
}

output "host" {
  description = "The DNS host for the API of the cluster"
  value       = "${azurerm_kubernetes_cluster.aks.0.kube_config.0.host}"
}

output "name" {
  description = "The resource name of the cluster"
  value       = "${azurerm_kubernetes_cluster.aks.name}"
}

resource "local_file" "kubeconfig" {
  content  = "${azurerm_kubernetes_cluster.aks.kube_config_raw}"
  filename = "${var.kubeconfig_path}"
}

output "cluster_ca_certificate" {
  description = "The cluster CA certificate"
  value       = "${base64decode(azurerm_kubernetes_cluster.aks.0.kube_config.0.cluster_ca_certificate)}"
  sensitive   = true
}

output "username" {
  value     = "${azurerm_kubernetes_cluster.aks.0.kube_config.0.username}"
  sensitive = false
}

output "password" {
  value     = "${azurerm_kubernetes_cluster.aks.0.kube_config.0.password}"
  sensitive = false
}
