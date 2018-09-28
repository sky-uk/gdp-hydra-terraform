output "ips" {
  description = "Map of the cluster IPs"
  value       = "${local.cluster_ips}"
}

output "kubeconfigs" {
  description = "Map of the kuber config files for all clusters. These files are also zipped up and uploaded to kubeconfig_url"
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

output "gcr_url" {
  description = "The URL of the docker registry for GCP clusters"
  value       = "${module.gcr.url}"
}

output "gcr_credentials" {
  description = "JSON credentials file for the docker registry for GCP clusters"
  sensitive   = true
  value       = "${module.gcr.credentials}"
}

output "acr_url" {
  description = "The URL of the docker registry for Azure clusters"
  value       = "${module.acr.url}"
}

output "acr_username" {
  description = "The username for the docker registry for Azure clusters"
  value       = "${module.acr.username}"
}

output "acr_password" {
  description = "The password for the docker registry for Azure clusters"
  sensitive   = true
  value       = "${module.acr.password}"
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
  value = "${module.monitoring.kubeconfig}"
}
