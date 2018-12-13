resource "helm_release" "cert_manager" {
  name      = "cert-manager"
  chart     = "stable/cert-manager"
  namespace = "kube-system"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  set {
    name  = "rbac.create"
    value = "false"
  }

  set {
    name  = "ingressShim.defaultIssuerName"
    value = "letsencrypt-staging"
  }

  set {
    name  = "ingressShim.defaultIssuerKind"
    value = "ClusterIssuer"
  }
}

resource "helm_release" "cluster_certificates" {
  name      = "cluster-certificates"
  chart     = "${path.module}/charts/cluster-certs"
  namespace = "kube-system"

  # workaround to stop CI from complaining about keyring change
  keyring = ""

  set {
    name  = "clusterIssuer.email"
    value = "${var.cluster_issuer_email}"
  }

  # chart is embedded in module and so path will change each time module path changes
  # it will still update when chart version is changed
  lifecycle {
    ignore_changes = ["chart"]
  }

  depends_on = [
    "helm_release.cert_manager",
  ]
}
