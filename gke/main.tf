locals {
  cluster_name = "${var.cluster_prefix}-${var.region}"
}

resource "google_container_cluster" "cluster" {
  project            = "${var.google_project}"
  name               = "${local.cluster_name}"
  location           = "${var.region}"
  initial_node_count = "${var.node_count}"
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

  logging_service = "none"

  // Offset each cluster maintance windows by 2 hours from each other
  maintenance_policy {
    daily_maintenance_window {
      start_time = "0${count.index*2}:00"
    }
  }

  resource_labels = "${var.tags}"
}

data "google_client_config" "current" {}

provider "kubernetes" {
  load_config_file = false

  host                   = "${google_container_cluster.cluster.0.endpoint}"
  token                  = "${data.google_client_config.current.access_token}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.cluster.0.master_auth.0.cluster_ca_certificate)}"
}

data "google_client_openid_userinfo" "me" {}

resource "kubernetes_cluster_role_binding" "user" {
  metadata {
    name = "provider-user-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind = "User"
    name = "${data.google_client_openid_userinfo.me.email}"
  }
}

data "template_file" "kubeconfig" {
  template = "${file("${path.module}/templates/kubeconfig.cert.tpl")}"

  vars {
    access_token               = "${data.google_client_config.current.access_token}"
    cluster_name               = "${google_container_cluster.cluster.name}"
    certificate_authority_data = "${google_container_cluster.cluster.0.master_auth.0.cluster_ca_certificate}"
    server                     = "https://${google_container_cluster.cluster.0.endpoint}"
  }
}
