output "cluster_dns_name" {
  value = "${akamai_gtm_property.hydra_property.0.id}.${akamai_gtm_property.hydra_property.0.domain}"
}

output "monitoring_dns_name" {
  value = "${akamai_gtm_property.monitoring_property.0.id}.${akamai_gtm_property.monitoring_property.0.domain}"
}
