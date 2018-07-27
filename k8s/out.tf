output "cluster_ingress_ip" {
  value = "${kubernetes_service.ingress_service.load_balancer_ingress.0.ip}"
}
