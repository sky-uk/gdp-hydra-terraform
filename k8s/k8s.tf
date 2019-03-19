# This module defines Kubernetes-specific configuration that apply to 
# all clusters except for the monitoring cluster.

provider "kubernetes" {
  client_certificate     = "${var.cluster_client_certificate}"
  client_key             = "${var.cluster_client_key}"
  cluster_ca_certificate = "${var.cluster_ca_certificate}"
  host                   = "${var.host}"
}

resource "kubernetes_service" "ingress_service" {
  metadata {
    name      = "terraform-ingress-controller"
    namespace = "kube-system"

    labels = {
      createdby  = "terraform"
      app        = "traefik"
      datacenter = "${var.cluster_name}"
    }
  }

  spec {
    selector {
      app     = "traefik"
      release = "traefik-ingress-controller"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 80
    }

    port {
      name        = "https"
      port        = 443
      target_port = 443
    }

    port {
      name        = "metrics"
      port        = 8080
      target_port = 8080
    }

    type = "LoadBalancer"
  }
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

resource "kubernetes_config_map" "elasticsearch" {
  # Only create this configmap if we have valid details
  count = "${var.elasticsearch_credentials["username"] == "empty" ? 0 : 1}"

  metadata {
    name      = "elastic-secrets"
    namespace = "monitoring"
  }

  data {
    username = "${var.elasticsearch_credentials["username"]}"
    password = "${var.elasticsearch_credentials["password"]}"
  }
}

resource "kubernetes_service" "elasticsearch" {
  # Only create this configmap if we have valid details
  count = "${var.elasticsearch_credentials["url"] == "empty" ? 0 : 1}"

  metadata {
    name      = "elasticsearch"
    namespace = "monitoring"
  }

  spec {
    type         = "ExternalName"
    externalName = "${var.elasticsearch_credentials["url"]}"
  }
}

resource "kubernetes_service" "jaeger_collector" {
  metadata {
    name      = "ext-jaeger-collector"
    namespace = "monitoring"
  }

  spec {
    type         = "ExternalName"
    externalName = "${var.monitoring_dns_name}"
  }
}
