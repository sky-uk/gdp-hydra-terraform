output "helm_traefik_name" {
  value = "${helm_release.traefik.metadata.0.name}"
}
