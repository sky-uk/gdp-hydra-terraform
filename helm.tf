module "helm_aks1" {
  source            = "helm"
  enable_traefik    = "${var.enable_traefik}"
  enable_prometheus = "${var.enable_prometheus}"

  cluster_ca_certificate = "${base64decode(module.aks_cluster_1.cluster_ca)}"
  host                   = "${module.aks_cluster_1.host}"
  kubeconfig_path        = "{local.aks1}"

  cluster_name           = "aks1"
  monitoring_dns_name    = "${module.akamai_config.monitoring_dns_name}"
  tiller_service_account = "${module.k8s_config_aks_1.tiller_service_account_name}"
  monitoring_namespace   = "${module.k8s_config_aks_1.monitoring_namespace}"
  logging_namespace      = "${module.k8s_config_aks_1.logging_namespace}"

  fluentd_ingress_ip = "${module.monitoring_k8s.ingress_ip}"

  // This forces the helm config to run after the
  // initial Kubernetes configuration module
  // to prevent race configuration
  depends_on_hack = "${module.k8s_config_aks_1.cluster_ingress_ip}"
}

module "cluster_services_aks1" {
  source = "cluster_services"

  enable_traefik = "${var.enable_traefik}"

  cluster_ca_certificate = "${base64decode(module.aks_cluster_1.cluster_ca)}"
  host                   = "${module.aks_cluster_1.host}"
  cluster_name           = "aks1"
  tiller_service_account = "${module.k8s_config_aks_1.tiller_service_account_name}"

  traefik_replica_count = "${var.traefik_replicas_count}"

  cluster_issuer_email = "${var.cluster_issuer_email}"
  kubeconfig_path      = "{local.aks2}"

  // This forces the helm config to run after the
  // initial Kubernetes configuration module
  // to prevent race configuration
  depends_on_hack = "${module.k8s_config_aks_1.cluster_ingress_ip}"
}

module "helm_aks2" {
  source            = "helm"
  enable_traefik    = "${var.enable_traefik}"
  enable_prometheus = "${var.enable_prometheus}"

  cluster_ca_certificate = "${base64decode(module.aks_cluster_2.cluster_ca)}"
  host                   = "${module.aks_cluster_2.host}"
  kubeconfig_path        = "{local.aks2}"

  cluster_name           = "aks2"
  monitoring_dns_name    = "${module.akamai_config.monitoring_dns_name}"
  tiller_service_account = "${module.k8s_config_aks_2.tiller_service_account_name}"
  monitoring_namespace   = "${module.k8s_config_aks_2.monitoring_namespace}"
  logging_namespace      = "${module.k8s_config_aks_2.logging_namespace}"

  fluentd_ingress_ip = "${module.monitoring_k8s.ingress_ip}"

  depends_on_hack = "${module.k8s_config_aks_2.cluster_ingress_ip}"
}

module "cluster_services_aks2" {
  source         = "cluster_services"
  enable_traefik = "${var.enable_traefik}"

  cluster_ca_certificate = "${base64decode(module.aks_cluster_2.cluster_ca)}"

  host                   = "${module.aks_cluster_2.host}"
  cluster_name           = "aks2"
  tiller_service_account = "${module.k8s_config_aks_2.tiller_service_account_name}"

  traefik_replica_count = "${var.traefik_replicas_count}"

  cluster_issuer_email = "${var.cluster_issuer_email}"
  kubeconfig_path      = "{local.aks2}"

  depends_on_hack = "${module.k8s_config_aks_2.cluster_ingress_ip}"
}

module "helm_gke1" {
  source            = "helm"
  enable_traefik    = "${var.enable_traefik}"
  enable_prometheus = "${var.enable_prometheus}"

  cluster_ca_certificate = "${base64decode(module.gke_cluster_1.cluster_ca)}"
  host                   = "${module.gke_cluster_1.host}"
  kubeconfig_path        = "{local.gke1}"

  cluster_name           = "gke1"
  monitoring_dns_name    = "${module.akamai_config.monitoring_dns_name}"
  tiller_service_account = "${module.k8s_config_gke_1.tiller_service_account_name}"
  monitoring_namespace   = "${module.k8s_config_gke_1.monitoring_namespace}"
  logging_namespace      = "${module.k8s_config_gke_1.logging_namespace}"
  fluentd_ingress_ip     = "${module.monitoring_k8s.ingress_ip}"

  depends_on_hack = "${module.k8s_config_gke_1.cluster_ingress_ip}"
}

module "cluster_services_gke1" {
  source         = "cluster_services"
  enable_traefik = "${var.enable_traefik}"

  cluster_ca_certificate = "${base64decode(module.gke_cluster_1.cluster_ca)}"
  host                   = "${module.gke_cluster_1.host}"
  cluster_name           = "gke1"

  traefik_replica_count  = "${var.traefik_replicas_count}"
  tiller_service_account = "${module.k8s_config_gke_1.tiller_service_account_name}"

  cluster_issuer_email = "${var.cluster_issuer_email}"
  kubeconfig_path      = "{local.gke1}"

  depends_on_hack = "${module.k8s_config_gke_1.cluster_ingress_ip}"
}

module "helm_gke2" {
  source            = "helm"
  enable_traefik    = "${var.enable_traefik}"
  enable_prometheus = "${var.enable_prometheus}"

  cluster_ca_certificate = "${base64decode(module.gke_cluster_2.cluster_ca)}"
  host                   = "${module.gke_cluster_2.host}"
  kubeconfig_path        = "{local.gke2}"

  cluster_name           = "gke2"
  monitoring_dns_name    = "${module.akamai_config.monitoring_dns_name}"
  tiller_service_account = "${module.k8s_config_gke_2.tiller_service_account_name}"
  monitoring_namespace   = "${module.k8s_config_gke_2.monitoring_namespace}"
  logging_namespace      = "${module.k8s_config_gke_2.logging_namespace}"

  fluentd_ingress_ip = "${module.monitoring_k8s.ingress_ip}"

  depends_on_hack = "${module.k8s_config_gke_2.cluster_ingress_ip}"
}

module "cluster_services_gke2" {
  source         = "cluster_services"
  enable_traefik = "${var.enable_traefik}"

  cluster_ca_certificate = "${base64decode(module.gke_cluster_2.cluster_ca)}"
  host                   = "${module.gke_cluster_2.host}"
  cluster_name           = "gke2"
  tiller_service_account = "${module.k8s_config_gke_2.tiller_service_account_name}"

  traefik_replica_count = "${var.traefik_replicas_count}"

  cluster_issuer_email = "${var.cluster_issuer_email}"
  kubeconfig_path      = "{local.gke2}"

  depends_on_hack = "${module.k8s_config_gke_2.cluster_ingress_ip}"
}

module "cluster_services_monitoring" {
  source = "cluster_services"

  enable_traefik = true

  cluster_ca_certificate = "${base64decode(module.monitoring_cluster.cluster_ca)}"
  host                   = "${module.monitoring_cluster.host}"
  cluster_name           = "gke2"
  tiller_service_account = "${module.monitoring_k8s.tiller_service_account_name}"
  traefik_replica_count  = "2"

  cluster_issuer_email = "${var.cluster_issuer_email}"
  kubeconfig_path      = "${local.monitoring}"
  depends_on_hack      = "${module.monitoring_cluster.host}"
}
