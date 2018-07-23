variable "organization" {
  description = "The GKE Organisation under which to create the cluster"
}

variable "kubernetes_version" {
  description = "The version of k8s to use for deployment"
}

variable "google_project" {
  description = "The google project in which to deploy the cluster"
}

variable "cluster_prefix" {
  description = "The cluster name prefix. This will be joined with the index of the cluster eg. cluster_prefix_1, cluster_prefix_2"
}

variable "node_count" {
  default = 1
}

variable "machine_type" {
  default = "n1-standard-1"
}

variable "region" {
  description = "The region in which to deploy a GKE cluster"
}

resource "google_container_cluster" "cluster" {
  project            = "${var.google_project}"
  name               = "${var.cluster_prefix}-${var.region}"
  zone               = "${var.region}"
  initial_node_count = "${var.node_count}"
  enable_legacy_abac = true
  min_master_version = "${var.kubernetes_version}"
  node_version       = "${var.kubernetes_version}"

  node_config {
    machine_type = "${var.machine_type}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  // Offset each cluster maintance windows by 2 hours from each other
  maintenance_policy {
    daily_maintenance_window {
      start_time = "0${count.index*2}:00"
    }
  }
}

data "template_file" "kubeconfig" {
  template = "${file("${path.module}/templates/kubeconfig.cert.tpl")}"

  vars {
    cluster_name               = "${google_container_cluster.cluster.name}"
    certificate_authority_data = "${google_container_cluster.cluster.0.master_auth.0.cluster_ca_certificate}"
    server                     = "https://${google_container_cluster.cluster.0.endpoint}"
    client_cert                = "${google_container_cluster.cluster.0.master_auth.0.client_certificate}"
    client_key                 = "${google_container_cluster.cluster.0.master_auth.0.client_key}"
  }
}

output "kubeconfig" {
  value     = "${data.template_file.kubeconfig.rendered}"
  sensitive = true
}

output "cluster_client_certificate" {
  value     = "${google_container_cluster.cluster.0.master_auth.0.client_certificate}"
  sensitive = true
}

output "cluster_client_key" {
  value     = "${google_container_cluster.cluster.0.master_auth.0.client_key}"
  sensitive = true
}

output "cluster_ca" {
  value     = "${google_container_cluster.cluster.0.master_auth.0.cluster_ca_certificate}"
  sensitive = true
}

output "host" {
  value = "${google_container_cluster.cluster.0.endpoint}"
}

output "username" {
  value = "${google_container_cluster.cluster.0.master_auth.0.username}"
}

output "password" {
  value     = "${google_container_cluster.cluster.0.master_auth.0.password}"
  sensitive = true
}

output "name" {
  value = "${google_container_cluster.cluster.name}"
}
