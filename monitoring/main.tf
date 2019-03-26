provider "kubernetes" {
  config_path            = "${var.host}.kubeconfig"
  load_config_file       = true
  cluster_ca_certificate = "${var.cluster_ca}"
  host                   = "${var.host}"
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

resource "null_resource" "helm_init" {
  provisioner "local-exec" {
    command = "helm init --service-account ${kubernetes_service_account.tiller.metadata.0.name} --wait --kubeconfig ${var.host}.kubeconfig"
  }

  depends_on = ["kubernetes_cluster_role_binding.tiller"]
}

provider "helm" {
  install_tiller  = true
  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.11.0"

  kubernetes {
    cluster_ca_certificate = "${var.cluster_ca}"
    host                   = "${var.host}"
  }
}
