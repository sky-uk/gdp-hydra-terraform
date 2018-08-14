variable "enabled" {}
variable "zone" {}
variable "dns_name" {}

variable "monitoring_endpoint_password" {}

variable "cluster_ips" {
  description = "Map of the IP addresses to the ingress of all clusters in the hydra deployment"
  type        = "map"
}

variable "aks_cluster_1_enabled" {
  description = "Enable the cluster in the Akamai traffic manager"
  default     = true
}

variable "aks_cluster_2_enabled" {
  description = "Enable the cluster in the Akamai traffic manager"
  default     = true
}

variable "gke_cluster_1_enabled" {
  description = "Enable the cluster in the Akamai traffic manager"
  default     = true
}

variable "gke_cluster_2_enabled" {
  description = "Enable the cluster in the Akamai traffic manager"
  default     = true
}

resource "cloudflare_load_balancer_monitor" "health" {
  count          = "${var.enabled}"
  expected_body  = ""
  expected_codes = "2xx"
  method         = "GET"
  timeout        = 5
  path           = "/healthz"
  interval       = 60
  retries        = 2
  description    = "hydra load test"

  header {
    header = "Authorization"
    values = ["Basic ${base64encode("admin:${var.monitoring_endpoint_password}")}"]
  }
}

resource "cloudflare_load_balancer" "hydra" {
  count = "${var.enabled}"
  zone  = "${var.zone}"
  name  = "${var.dns_name}.${var.zone}"

  fallback_pool_id = "${cloudflare_load_balancer_pool.fallback_pool.id}"

  default_pool_ids = [
    "${cloudflare_load_balancer_pool.hydra_clusters.id}",
    "${cloudflare_load_balancer_pool.aks_clusters.id}",
    "${cloudflare_load_balancer_pool.gke_clusters.id}",
  ]

  description = "Load balancer for hyra [Created by Terraform]"
  proxied     = true
}

resource "cloudflare_load_balancer_pool" "fallback_pool" {
  count = "${var.enabled}"
  name  = "fallback_pool"

  origins {
    name    = "aks_cluster_1"
    address = "status.azure.com"
    enabled = "true"
  }
}

resource "cloudflare_load_balancer_pool" "hydra_clusters" {
  count = "${var.enabled}"
  name  = "hydra_clusters"

  monitor = "${cloudflare_load_balancer_monitor.health.id}"

  origins {
    name    = "aks_cluster_1"
    address = "${var.cluster_ips["aks_cluster_1"]}"
    enabled = "${var.aks_cluster_1_enabled}"
  }

  origins {
    name    = "aks_cluster_2"
    address = "${var.cluster_ips["aks_cluster_2"]}"
    enabled = "${var.aks_cluster_1_enabled}"
  }

  origins {
    name    = "gke_cluster_1"
    address = "${var.cluster_ips["gke_cluster_1"]}"
    enabled = "${var.aks_cluster_1_enabled}"
  }

  origins {
    name    = "gke_cluster_2"
    address = "${var.cluster_ips["gke_cluster_2"]}"
    enabled = "${var.aks_cluster_1_enabled}"
  }
}

resource "cloudflare_load_balancer_pool" "aks_clusters" {
  count = "${var.enabled}"
  name  = "aks_clusters"

  monitor = "${cloudflare_load_balancer_monitor.health.id}"


  origins {
    name    = "aks_cluster_1"
    address = "${var.cluster_ips["aks_cluster_1"]}"
    enabled = "${var.aks_cluster_1_enabled}"
  }

  origins {
    name    = "aks_cluster_2"
    address = "${var.cluster_ips["aks_cluster_2"]}"
    enabled = "${var.aks_cluster_2_enabled}"
  }
}

resource "cloudflare_load_balancer_pool" "gke_clusters" {
  count = "${var.enabled}"
  name  = "gke_clusters"

  monitor = "${cloudflare_load_balancer_monitor.health.id}"


  origins {
    name    = "gke_cluster_1"
    address = "${var.cluster_ips["gke_cluster_1"]}"
    enabled = "${var.gke_cluster_1_enabled}"
  }

  origins {
    name    = "gke_cluster_2"
    address = "${var.cluster_ips["gke_cluster_2"]}"
    enabled = "${var.gke_cluster_1_enabled}"
  }
}

output "edge_url" {
  value = "${var.dns_name}.${var.zone}"
}
