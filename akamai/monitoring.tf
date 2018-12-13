
resource "akamai_gtm_data_center" "monitoring" {
  count     = "${var.enabled}"
  name      = "monitoring"
  domain    = "${akamai_gtm_domain.hydra_domain.name}"
  country   = "GB"
  continent = "EU"
  city      = "Leeds"
  longitude = -5.582
  latitude  = 54.367

  depends_on = [
    "akamai_gtm_domain.hydra_domain",
  ]
}

resource "akamai_gtm_property" "monitoring_property" {
  count = "${var.enabled}"

  depends_on = []

  domain                      = "${akamai_gtm_domain.hydra_domain.name}"
  type                        = "weighted-round-robin"
  name                        = "${var.dns_name}-monitoring"
  balance_by_download_score   = false
  dynamic_ttl                 = 30
  failover_delay              = 15
  failback_delay              = 15
  handout_mode                = "normal"
  health_threshold            = 0
  health_max                  = 0
  health_multiplier           = 0
  load_imbalance_percentage   = 10
  ipv6                        = false
  score_aggregation_type      = "mean"
  static_ttl                  = 600
  stickiness_bonus_percentage = 50
  stickiness_bonus_constant   = 0
  use_computed_targets        = false

  traffic_target {
    enabled        = true
    data_center_id = "${akamai_gtm_data_center.monitoring.id}"
    weight         = 1.0
    name           = "${akamai_gtm_data_center.azure_1.name}"

    servers = [
      "${var.monitoring_cluster_ips}",
    ]
  }
}