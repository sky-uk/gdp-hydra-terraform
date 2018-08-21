module "helm_aks1" {
  source            = "helm"
  enable_traefik    = "${var.enable_traefik}"
  enable_prometheus = "${var.enable_prometheus}"

  client_certificate     = "${base64decode(module.aks_cluster_1.cluster_client_certificate)}"
  client_key             = "${base64decode(module.aks_cluster_1.cluster_client_key)}"
  cluster_ca_certificate = "${base64decode(module.aks_cluster_1.cluster_ca)}"
  host                   = "${module.aks_cluster_1.host}"
  cluster_name           = "aks1"

  traefik_replica_count = "${var.traefik_replicas_count}"

  // This forces the helm config to run after the
  // initial Kubernetes configuration module 
  // to prevent race configuration
  depends_on_hack = "${module.k8s_config_aks_1.cluster_ingress_ip}"
}

module "helm_aks2" {
  source            = "helm"
  enable_traefik    = "${var.enable_traefik}"
  enable_prometheus = "${var.enable_prometheus}"

  client_certificate     = "${base64decode(module.aks_cluster_2.cluster_client_certificate)}"
  client_key             = "${base64decode(module.aks_cluster_2.cluster_client_key)}"
  cluster_ca_certificate = "${base64decode(module.aks_cluster_2.cluster_ca)}"
  host                   = "${module.aks_cluster_2.host}"
  cluster_name           = "aks2"

  traefik_replica_count = "${var.traefik_replicas_count}"

  depends_on_hack = "${module.k8s_config_aks_2.cluster_ingress_ip}"
}

module "helm_gke1" {
  source            = "helm"
  enable_traefik    = "${var.enable_traefik}"
  enable_prometheus = "${var.enable_prometheus}"

  client_certificate     = "${base64decode(module.gke_cluster_1.cluster_client_certificate)}"
  client_key             = "${base64decode(module.gke_cluster_1.cluster_client_key)}"
  cluster_ca_certificate = "${base64decode(module.gke_cluster_1.cluster_ca)}"
  host                   = "${module.gke_cluster_1.host}"
  cluster_name           = "gke1"  

  traefik_replica_count = "${var.traefik_replicas_count}"

  depends_on_hack = "${module.k8s_config_gke_1.cluster_ingress_ip}"
}

module "helm_gke2" {
  source            = "helm"
  enable_traefik    = "${var.enable_traefik}"
  enable_prometheus = "${var.enable_prometheus}"

  client_certificate     = "${base64decode(module.gke_cluster_2.cluster_client_certificate)}"
  client_key             = "${base64decode(module.gke_cluster_2.cluster_client_key)}"
  cluster_ca_certificate = "${base64decode(module.gke_cluster_2.cluster_ca)}"
  host                   = "${module.gke_cluster_2.host}"
  cluster_name           = "gke2"  

  traefik_replica_count = "${var.traefik_replicas_count}"

  depends_on_hack = "${module.k8s_config_gke_2.cluster_ingress_ip}"
}
