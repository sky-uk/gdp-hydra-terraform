output "kubeconfig" {
  description = "The kubeconfig file that can be used to access the cluster that has been created"
  value       = "${azurerm_kubernetes_cluster.aks.kube_config_raw}"
  sensitive   = true
}

output "cluster_client_certificate" {
  description = "The client certificate used for connecting to the cluster"
  value       = "${azurerm_kubernetes_cluster.aks.0.kube_config.0.client_certificate}"
  sensitive   = true
}

output "cluster_client_key" {
  description = "The client key used for connecting to the cluster"
  value       = "${azurerm_kubernetes_cluster.aks.0.kube_config.0.client_key}"
  sensitive   = true
}

output "cluster_ca" {
  description = "The cluster CA certificate"
  value       = "${azurerm_kubernetes_cluster.aks.0.kube_config.0.cluster_ca_certificate}"
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
