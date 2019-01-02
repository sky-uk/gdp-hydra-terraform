output "kubeconfig" {
  value     = "${module.monitoring_cluster.kubeconfig}"
  sensitive = true
}

output "monitoring_cluster_ips" {
  value = "${data.kubernetes_service.ingress.load_balancer_ingress.0.ip}"
}


output "fluentd_ingress_ip" {
  value = "${data.kubernetes_service.fluentd.load_balancer_ingress.0.ip}"
}