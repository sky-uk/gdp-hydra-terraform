resource "akamai_gtm_domain" "hydra_domain" {
  count = "${var.enabled}"
  name  = "${var.zone}"
  type  = "basic"
}

resource "akamai_gtm_data_center" "azure_1" {
  count     = "${var.enabled}"
  name      = "azure_1"
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

resource "akamai_gtm_data_center" "azure_2" {
  count     = "${var.enabled}"
  name      = "azure_2"
  domain    = "${akamai_gtm_domain.hydra_domain.name}"
  country   = "GB"
  continent = "EU"
  city      = "Leeds"
  longitude = -5.582
  latitude  = 54.367

  depends_on = [
    "akamai_gtm_data_center.azure_1",
  ]
}

resource "akamai_gtm_data_center" "google_1" {
  count     = "${var.enabled}"
  name      = "google_1"
  domain    = "${akamai_gtm_domain.hydra_domain.name}"
  country   = "GB"
  continent = "EU"
  city      = "Leeds"
  longitude = -5.582
  latitude  = 54.367

  depends_on = [
    "akamai_gtm_data_center.azure_2",
  ]
}

resource "akamai_gtm_data_center" "google_2" {
  count = "${var.enabled}"

  name      = "google_2"
  domain    = "${akamai_gtm_domain.hydra_domain.name}"
  country   = "GB"
  continent = "EU"
  city      = "Leeds"
  longitude = -5.582
  latitude  = 54.367

  depends_on = [
    "akamai_gtm_data_center.google_1",
  ]
}

resource "akamai_gtm_property" "hydra_property" {
  count = "${var.enabled}"

  depends_on = []

  domain                      = "${akamai_gtm_domain.hydra_domain.name}"
  type                        = "weighted-round-robin"
  name                        = "${var.dns_name}"
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

  liveness_test {
    name                             = "health check"
    test_object                      = "/healthz"
    test_object_username             = "admin"
    test_object_password             = "monitor"
    test_object_protocol             = "HTTP"
    test_interval                    = 15
    disable_nonstandard_port_warning = false
    http_error_4xx                   = true
    http_error_3xx                   = true
    http_error_5xx                   = true
    test_object_port                 = 80
    test_timeout                     = 4
  }

  traffic_target {
    enabled        = "${var.aks_cluster_1_enabled}"
    data_center_id = "${akamai_gtm_data_center.azure_1.id}"
    weight         = 1.0
    name           = "${akamai_gtm_data_center.azure_1.name}"

    servers = [
      "${var.cluster_ips["aks_cluster_1"]}",
    ]
  }

  traffic_target {
    enabled        = "${var.aks_cluster_2_enabled}"
    data_center_id = "${akamai_gtm_data_center.azure_2.id}"
    weight         = 1.0
    name           = "${akamai_gtm_data_center.azure_2.name}"

    # handout_cname  = "www.google.com"

    servers = [
      "${var.cluster_ips["aks_cluster_2"]}",
    ]
  }

  traffic_target {
    enabled        = "${var.gke_cluster_1_enabled}"
    data_center_id = "${akamai_gtm_data_center.google_1.id}"
    weight         = 1.0
    name           = "${akamai_gtm_data_center.google_1.name}"

    # handout_cname  = "www.comcast.com"

    servers = [
      "${var.cluster_ips["gke_cluster_1"]}",
    ]
  }

  traffic_target {
    enabled        = "${var.gke_cluster_2_enabled}"
    data_center_id = "${akamai_gtm_data_center.google_2.id}"
    weight         = 1.0
    name           = "${akamai_gtm_data_center.google_2.name}"

    # handout_cname  = "www.comcast.com"

    servers = [
      "${var.cluster_ips["gke_cluster_2"]}",
    ]
  }

  # traffic_target {
  #   count          = "${length(var.cluster_ips)}"
  #   enabled        = true
  #   data_center_id = "${akamai_gtm_data_center.azure.id}"
  #   weight         = 1.0
  #   name           = "${akamai_gtm_data_center.azure.name}"

  #   servers = ["${var.cluster_ips[count.index]}"]
  # }
}
