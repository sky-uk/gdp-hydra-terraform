output "kubeconfig" {
  description = "The kuberconfig file for the cluster"
  value       = "${data.template_file.kubeconfig.rendered}"
  sensitive   = true
}

output "host" {
  description = "The DNS host for the API of the cluster"
  value       = "${google_container_cluster.cluster.0.endpoint}"
}

output "name" {
  description = "The resource name of the cluster"
  value       = "${google_container_cluster.cluster.name}"
}

resource "local_file" "kubeconfig" {
  content  = "${data.template_file.kubeconfig.rendered}"
  filename = "${var.kubeconfig_path}"
}

output "cluster_ca_certificate" {
  description = "The cluster CA certificate"
  value       = "${google_container_cluster.cluster.0.master_auth.0.cluster_ca_certificate}"
  sensitive   = true
}

output "access_token" {
  value = "${data.google_client_config.current.access_token}"
}
