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

  enable_helm_deployment = false

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

output "ips" {
  value = "${module.hydra.ips}"
}

output "kubeconfigs" {
  value = "${module.hydra.kubeconfigs}"
}
