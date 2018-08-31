output "kubeconfig" {
  value     = "${module.monitoring_cluster.kubeconfig}"
  sensitive = true
}
