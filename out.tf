output "ips" {
  value = "${local.cluster_ips}"
}

output "kubeconfigs" {
  sensitive = true

  value = {
    "aks_cluster_1" = "${module.aks_cluster_1.kubeconfig}"
    "aks_cluster_2" = "${module.aks_cluster_2.kubeconfig}"
    "gke_cluster_1" = "${module.gke_cluster_1.kubeconfig}"
    "gke_cluster_2" = "${module.gke_cluster_2.kubeconfig}"
  }
}

output "edge_url" {
  value = "${module.akamai_config.edge_url}"
}

output "gcr_location" {
  value = "${module.gcr.url}"
}

output "gcr_credentials" {
  sensitive = true
  value     = "${module.gcr.credentials}"
}

output "acr_location" {
  value = "${module.acr.url}"
}

output "acr_username" {
  value = "${module.acr.username}"
}

output "acr_password" {
  sensitive = true
  value     = "${module.acr.password}"
}
