output "monitoring_cluster_ips" {
  value = "${data.kubernetes_service.ingress.load_balancer_ingress.0.ip}"
}

output "fluentd_ingress_ip" {
  value = "${data.kubernetes_service.fluentd.load_balancer_ingress.0.ip}"
}

output "tiller_service_account_name" {
  value = "${kubernetes_service_account.tiller.metadata.0.name}"
}

output "kubeconfig" {
  value     = "${module.monitoring_cluster.kubeconfig}"
  sensitive = true
}
