provider "kubernetes" {
  client_certificate     = "${base64decode(module.monitoring_cluster.cluster_client_certificate)}"
  client_key             = "${base64decode(module.monitoring_cluster.cluster_client_key)}"
  cluster_ca_certificate = "${base64decode(module.monitoring_cluster.cluster_ca)}"
  host                   = "${module.monitoring_cluster.host}"
}

# create service account for tiller - server side of Helm
resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller-service-account"
    namespace = "kube-system"
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

resource "kubernetes_service" "ingress_service" {
  metadata {
    name      = "traefik-ingress-controller"
    namespace = "kube-system"

    labels = {
      createdby  = "terraform"
      app        = "traefik"
      datacenter = "${var.cluster_prefix}"
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

resource "kubernetes_namespace" "monitoring" {
  metadata {
    labels = {
      createdby  = "terraform"
      datacenter = "${var.cluster_prefix}"
    }

    name = "monitoring"
  }
}

resource "kubernetes_namespace" "logging" {
  metadata {
    labels = {
      createdby  = "terraform"
      datacenter = "${var.cluster_prefix}"
    }

    name = "logging"
  }
}

resource "local_file" "kubeconfig" {
  content  = "${module.monitoring_cluster.kubeconfig}"
  filename = "${module.monitoring_cluster.host}.kubeconfig"
}

resource "null_resource" "helm_init" {
  provisioner "local-exec" {
    command = "helm init --service-account ${kubernetes_service_account.tiller.metadata.0.name} --wait --kubeconfig ${local_file.kubeconfig.filename}"
  }

  depends_on = ["kubernetes_cluster_role_binding.tiller"]
}

provider "helm" {
  install_tiller  = true
  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.11.0"

  kubernetes {
    client_certificate     = "${base64decode(module.monitoring_cluster.cluster_client_certificate)}"
    client_key             = "${base64decode(module.monitoring_cluster.cluster_client_key)}"
    cluster_ca_certificate = "${base64decode(module.monitoring_cluster.cluster_ca)}"
    host                   = "${module.monitoring_cluster.host}"
  }
}
