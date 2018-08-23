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

  resource_labels = "${var.tags}"
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
