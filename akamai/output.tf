output "edge_url" {
  description = "The edge url exposed from the Akamai traffic manager"
  value       = "${akamai_gtm_property.hydra_property.name}${akamai_gtm_domain.hydra_domain.name}"
}
