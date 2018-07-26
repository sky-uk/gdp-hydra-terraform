output "kubeconfig" {
  description = "The kuberconfig file for the cluster"
  value       = "${data.template_file.kubeconfig.rendered}"
  sensitive   = true
}

output "cluster_client_certificate" {
  description = "The client certificate used for connecting to the cluster"
  value       = "${google_container_cluster.cluster.0.master_auth.0.client_certificate}"
  sensitive   = true
}

output "cluster_client_key" {
  description = "The client key used for connecting to the cluster"
  value       = "${google_container_cluster.cluster.0.master_auth.0.client_key}"
  sensitive   = true
}

output "cluster_ca" {
  description = "The cluster CA certificate"
  value       = "${google_container_cluster.cluster.0.master_auth.0.cluster_ca_certificate}"
  sensitive   = true
}

output "host" {
  description = "The DNS host for the API of the cluster"
  value       = "${google_container_cluster.cluster.0.endpoint}"
}

output "username" {
  value = "${google_container_cluster.cluster.0.master_auth.0.username}"
}

output "password" {
  value     = "${google_container_cluster.cluster.0.master_auth.0.password}"
  sensitive = true
}

output "name" {
  description = "The resource name of the cluster"
  value       = "${google_container_cluster.cluster.name}"
}
