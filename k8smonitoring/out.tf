output "tiller_service_account_name" {
  value = "${kubernetes_service_account.tiller.metadata.0.name}"
}

output "monitoring_namespace" {
  value = "${kubernetes_namespace.monitoring.metadata.0.name}"
}

output "logging_namespace" {
  value = "${kubernetes_namespace.logging.metadata.0.name}"
}

output "ingress_ip" {
  value = "${data.kubernetes_service.ingress.load_balancer_ingress.0.ip}"
}
