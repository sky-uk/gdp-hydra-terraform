# This module defines Kubernetes-specific configuration that apply to
# all clusters except for the monitoring cluster.

provider "kubernetes" {
  host                   = "${var.host}"
  cluster_ca_certificate = "${var.cluster_ca_certificate}"
  client_certificate     = "${var.cluster_client_certificate}"
  client_key             = "${var.cluster_client_key}"
  username               = "${var.username}"
  password               = "${var.password}"
}

data "kubernetes_service" "ingress" {
  metadata {
    name      = "${var.ingress_controller}"
    namespace = "kube-system"
  }

  depends_on = ["kubernetes_service.jaeger_collector"]
}

# create service account for tiller - server side of Helm
resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller-service-account"
    namespace = "kube-system"
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    labels = {
      createdby  = "terraform"
      datacenter = "${var.cluster_name}"
    }

    name = "monitoring"
  }

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

resource "kubernetes_namespace" "logging" {
  metadata {
    labels = {
      createdby  = "terraform"
      datacenter = "${var.cluster_name}"
    }

    name = "logging"
  }

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

# allow tiller do the stuff :)
resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller-cluster-rule"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.tiller.metadata.0.name}"
    api_group = ""
    namespace = "${kubernetes_service_account.tiller.metadata.0.namespace}"
  }
}

resource "kubernetes_service" "jaeger_collector" {
  metadata {
    name      = "ext-jaeger-collector"
    namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"
  }

  spec {
    type          = "ExternalName"
    external_name = "${var.monitoring_dns_name}"
  }
}
