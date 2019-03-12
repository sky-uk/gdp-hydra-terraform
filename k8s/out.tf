output "cluster_ingress_ip" {
  value = "${kubernetes_service.ingress_service.load_balancer_ingress.0.ip}"

  //The helm elements depend on some of the items created in this module
  // as modules don’t support the depends_on syntax we abuse this output variable
  // to have the same effect. 
  depends_on = [
    "kubernetes_deployment.hc-app",
    "kubernetes_ingress.hc-ingress",
    "kubernetes_ingress.prometheus-ingress",
    "kubernetes_namespace.healthcheck",
    "kubernetes_namespace.monitoring",
    "kubernetes_secret.image_pull_secret",
    "kubernetes_service.hc-service",
    "kubernetes_service.ingress_service",
  ]
}

output "tiller_service_account_name" {
  value = "${kubernetes_service_account.tiller.metadata.0.name}"
}

output "monitoring_namespace" {
  value = "${kubernetes_namespace.monitoring.metadata.0.name}"
}

output "logging_namespace" {
  value = "${kubernetes_namespace.logging.metadata.0.name}"
}
