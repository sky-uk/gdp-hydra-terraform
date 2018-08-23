variable project_name {}
variable google_project_id {}
variable google_creds_base64 {}
variable azure_client_id {}
variable azure_client_secret {}
variable azure_tenant_id {}
variable azure_subscription_id {}
variable cloudflare_email {}
variable cloudflare_token {}
variable edge_dns_zone {}
variable edge_dns_name {}

module "hydra" {
  source = "../"

  project_name = "${var.project_name}"

  enable_traefik    = true
  enable_prometheus = true

  monitoring_endpoint_password = "monitor"
  traefik_replicas_count       = 3

  node_type  = "small"
  node_count = 3

  azure_client_id       = "${var.azure_client_id}"
  azure_client_secret   = "${var.azure_client_secret}"
  azure_tenant_id       = "${var.azure_tenant_id}"
  azure_subscription_id = "${var.azure_subscription_id}"
  azure_node_ssh_key    = "${file("~/.ssh/id_rsa.pub")}"

  google_creds_base64 = "${var.google_creds_base64}"
  google_project_id   = "${var.google_project_id}"

  edge_dns_zone = "${var.edge_dns_zone}"
  edge_dns_name = "${var.edge_dns_name}"

  akamai_enabled       = false
  akamai_host          = ""
  akamai_client_secret = ""
  akamai_access_token  = ""
  akamai_client_token  = ""

  cloudflare_enabled = true
  cloudflare_email   = "${var.cloudflare_email}"
  cloudflare_token   = "${var.cloudflare_token}"
}

// Below we use the credentials from each of the clusters to deploy Kuberentes objects
// you can also do the same with the helm provider https://github.com/mcuadros/terraform-provider-helm
module "aks_1_deploy" {
  source = "./deploy"

  cluster_client_certificate = "${lookup(module.hydra.kube_conn_details["aks_cluster_1"], "cluster_client_certificate")}"
  cluster_client_key         = "${lookup(module.hydra.kube_conn_details["aks_cluster_1"], "cluster_client_key")}"
  cluster_ca_certificate     = "${lookup(module.hydra.kube_conn_details["aks_cluster_1"], "cluster_ca_certificate")}"
  host                       = "${lookup(module.hydra.kube_conn_details["aks_cluster_1"], "host")}"
}

module "aks_2_deploy" {
  source = "./deploy"

  cluster_client_certificate = "${lookup(module.hydra.kube_conn_details["aks_cluster_2"], "cluster_client_certificate")}"
  cluster_client_key         = "${lookup(module.hydra.kube_conn_details["aks_cluster_2"], "cluster_client_key")}"
  cluster_ca_certificate     = "${lookup(module.hydra.kube_conn_details["aks_cluster_2"], "cluster_ca_certificate")}"
  host                       = "${lookup(module.hydra.kube_conn_details["aks_cluster_2"], "host")}"
}

module "gke_1_deploy" {
  source = "./deploy"

  cluster_client_certificate = "${lookup(module.hydra.kube_conn_details["gke_cluster_1"], "cluster_client_certificate")}"
  cluster_client_key         = "${lookup(module.hydra.kube_conn_details["gke_cluster_1"], "cluster_client_key")}"
  cluster_ca_certificate     = "${lookup(module.hydra.kube_conn_details["gke_cluster_1"], "cluster_ca_certificate")}"
  host                       = "${lookup(module.hydra.kube_conn_details["gke_cluster_1"], "host")}"
}

module "gke_2_deploy" {
  source = "./deploy"

  cluster_client_certificate = "${lookup(module.hydra.kube_conn_details["gke_cluster_2"], "cluster_client_certificate")}"
  cluster_client_key         = "${lookup(module.hydra.kube_conn_details["gke_cluster_2"], "cluster_client_key")}"
  cluster_ca_certificate     = "${lookup(module.hydra.kube_conn_details["gke_cluster_2"], "cluster_ca_certificate")}"
  host                       = "${lookup(module.hydra.kube_conn_details["gke_cluster_2"], "host")}"
}

output "ips" {
  value = "${module.hydra.ips}"
}

output "url" {
  value = "${module.hydra.kubeconfig_url}"
}
