resource "azurerm_resource_group" "monitoring" {
  name     = "${var.project_name}-monitoring"
  location = "northeurope"

  tags = "${var.tags}"
}

resource "random_string" "storage_name" {
  keepers = {
    # Generate a new id each time we switch to a new resource group
    group_name = "${var.project_name}"
  }

  length  = 8
  upper   = false
  special = false
  number  = false
}

resource "azurerm_storage_account" "monitoring" {
  name                = "${format("%.24s", "${var.project_name}${random_string.storage_name.result}")}"
  resource_group_name = "${azurerm_resource_group.monitoring.name}"
  location            = "${azurerm_resource_group.monitoring.location}"
  account_tier        = "Standard"

  account_replication_type = "LRS"

  tags = "${var.tags}"
}

data "template_file" "promconfig" {
  template = "${file("${path.module}/template/master.prometheus.tpl")}"

  vars {
    AKS_CLUSTER_PROMETEHUS_SVC_IP_1 = "${var.cluster_ips["aks_cluster_1"]}"
    AKS_CLUSTER_PROMETEHUS_SVC_IP_2 = "${var.cluster_ips["aks_cluster_2"]}"
    GKE_CLUSTER_PROMETHEUS_SVC_IP_1 = "${var.cluster_ips["gke_cluster_1"]}"
    GKE_CLUSTER_PROMETHEUS_SVC_IP_2 = "${var.cluster_ips["gke_cluster_2"]}"
  }
}

resource "local_file" "promconfig" {
  content  = "${data.template_file.promconfig.rendered}"
  filename = "${path.module}/prometheus.yml"
}

resource "azurerm_storage_share" "prom-share" {
  name = "prometheus"

  resource_group_name  = "${azurerm_resource_group.monitoring.name}"
  storage_account_name = "${azurerm_storage_account.monitoring.name}"

  quota = 50

  provisioner "local-exec" {
    command = "az storage file upload --account-name ${azurerm_storage_account.monitoring.name} --account-key ${azurerm_storage_account.monitoring.primary_access_key} --share-name ${azurerm_storage_share.prom-share.0.name} --source ${path.module}/prometheus.yml"
  }

  depends_on = ["local_file.promconfig"]
}

resource "random_string" "grafana_password" {
  keepers = {
    # Generate a new id each time we change the project name
    group_name = "${var.project_name}"
  }

  length  = 8
  upper   = true
  special = false
  number  = true
}

locals {
  monitoring_url = "${var.project_name}-monitoring-${random_string.storage_name.result}"
  grafana_port   = "3000"
  prom_port      = "9090"
}

resource "azurerm_container_group" "monitoring" {
  name                = "${var.project_name}-monitoring"
  location            = "${azurerm_resource_group.monitoring.location}"
  resource_group_name = "${azurerm_resource_group.monitoring.name}"
  ip_address_type     = "public"
  dns_name_label      = "${local.monitoring_url}"
  os_type             = "linux"

  container {
    name   = "graf"
    image  = "grafana/grafana:5.2.3"
    cpu    = "1"
    memory = "2"
    port   = "${local.grafana_port}"

    environment_variables {
      "GF_SERVER_DOMAIN"           = "${local.monitoring_url}.${azurerm_resource_group.monitoring.location}.azurecontainer.io"
      "GF_SERVER_ROOT_URL"         = "http://${local.monitoring_url}.${azurerm_resource_group.monitoring.location}.azurecontainer.io:${local.grafana_port}/"
      "GF_SERVER_HTTP_PORT"        = "${local.grafana_port}"
      "GF_SECURITY_ADMIN_PASSWORD" = "${random_string.grafana_password.result}"
    }
  }

  container {
    name   = "prom"
    image  = "prom/prometheus:v2.3.2"
    cpu    = "1"
    memory = "2"
    port   = "${local.prom_port}"

    volume {
      name       = "prometheus-config"
      mount_path = "/etc/prometheus"
      read_only  = false
      share_name = "${azurerm_storage_share.prom-share.name}"

      storage_account_name = "${azurerm_storage_account.monitoring.name}"
      storage_account_key  = "${azurerm_storage_account.monitoring.primary_access_key}"
    }
  }

  tags = "${var.tags}"

  depends_on = ["azurerm_storage_share.prom-share"]

  # Make terraform wait until the services are up before proceeding.
  provisioner "local-exec" {
    timeouts {
      create = "5m"
      delete = "5m"
    }

    command = "until curl -s ${azurerm_container_group.monitoring.ip_address}:${local.grafana_port}/; do sleep 1; done"
  }
}

provider "grafana" {
  url  = "http://${local.monitoring_url}.${azurerm_resource_group.monitoring.location}.azurecontainer.io:${local.grafana_port}/"
  auth = "admin:${random_string.grafana_password.result}"
}

resource "grafana_data_source" "prometheus" {
  type = "prometheus"
  name = "prom"
  url  = "http://${local.monitoring_url}.${azurerm_resource_group.monitoring.location}.azurecontainer.io:${local.prom_port}/"

  depends_on = ["azurerm_container_group.monitoring"]
}

resource "grafana_dashboard" "traefik" {
  config_json = "${file("${path.module}/template/grafana-dashboard-traefik.json")}"
  depends_on  = ["grafana_data_source.prometheus"]
}
