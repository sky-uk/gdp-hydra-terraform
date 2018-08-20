output "cluster_ingress_ip" {
  value = "${kubernetes_service.ingress_service.load_balancer_ingress.0.ip}"

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
