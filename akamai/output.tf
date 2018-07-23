output "edge_url" {
  value = "${akamai_gtm_property.hydra_property.name}${akamai_gtm_domain.hydra_domain.name}"
}
