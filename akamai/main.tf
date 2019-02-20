resource "akamai_gtm_domain" "hydra_domain" {
  count = "${var.enabled}"
  name  = "${var.zone}"
  type  = "basic"
}
