data "kubernetes_service" "ingress" {
  metadata {
    name      = "traefik-ingress-controller"
    namespace = "kube-system"
  }
}

output "ips" {
  description = "Map of the cluster IPs"
  value       = "${local.cluster_ips}"
}

output "kubeconfigs" {
  description = "Map of the kube config files for all clusters. These files are also zipped up and uploaded to kubeconfig_url"
  sensitive   = true

  value = {
    "aks_cluster_1" = "${module.aks_cluster_1.kubeconfig}"
    "aks_cluster_2" = "${module.aks_cluster_2.kubeconfig}"
    "gke_cluster_1" = "${module.gke_cluster_1.kubeconfig}"
    "gke_cluster_2" = "${module.gke_cluster_2.kubeconfig}"
  }
}

output "edge_url" {
  description = "The URL of the edge routing (Akamai or Cloudflare)"
  value       = "${var.edge_dns_name}.${var.edge_dns_zone}"
}

output "kubeconfig_url" {
  description = "URL for zip file containing all of the cluster kubeconfigs, this link includes a SAS token and will grant access to all users. This can be used as part of CI processes to access all clusters."
  sensitive   = true
  value       = "${azurerm_storage_blob.kubeconfig.url}${data.azurerm_storage_account_sas.config_container_sas.sas}"
}

# output "prometheus_url" {
#   description = "URL of the central prometheus instance that scrapes from all clusters to aggregate information"
#   value       = "${module.monitoring.prometheus_url}"
# }

# output "grafana_url" {
#   description = "URL of the central grafana instance that is connected to the central prometheus"
#   value       = "${module.monitoring.grafana_url}"
# }

output "monitoring_kubeconfig" {
  value = "${module.monitoring_cluster.kubeconfig}"
}

output "cluster_dns_name" {
  value = "${module.akamai_config.cluster_dns_name}"
}

output "monitoring_dns_name" {
  value = "${module.akamai_config.monitoring_dns_name}"
}

output "monitoring_prometheus_username" {
  value = "${var.prom_metrics_username}"
}

output "monitoring_prometheus_password" {
  value = "${random_string.prom_metrics_password.result}"
}
