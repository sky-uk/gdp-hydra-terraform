variable "sp_name" {}

resource "azuread_application" "aks_app" {
  name = "${var.sp_name}"
}

resource "azuread_service_principal" "aks_sp" {
  application_id = "${azuread_application.aks_app.application_id}"
}

resource "random_string" "aks_sp_password" {
  length  = 16
  special = true

  keepers = {
    service_principal = "${azuread_service_principal.aks_sp.id}"
  }
}

resource "azuread_service_principal_password" "aks_sp_password" {
  service_principal_id = "${azuread_service_principal.aks_sp.id}"
  value                = "${random_string.aks_sp_password.result}"
  end_date             = "${timeadd(timestamp(), "8760h")}"

  # This stops be 'end_date' changing on each run and causing a new password to be set
  # to get the date to change here you would have to manually taint this resource...
  lifecycle {
    ignore_changes = ["end_date"]
  }

  // Add a delay to allow resource to propogate
}

resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 120"
  }

  triggers = {
    "runafter" = "${azuread_service_principal_password.aks_sp_password.service_principal_id}"
  }
}

output "sp_object_id" {
  depends_on = ["null_resource.delay"]
  value      = "${azuread_service_principal.aks_sp.id}"
}

output "application_id" {
  depends_on = ["null_resource.delay"]

  value = "${azuread_service_principal.aks_sp.application_id}"

  depends_on = [
    "${azuread_service_principal.aks_sp}",
  ]
}

output "sp_password" {
  depends_on = ["null_resource.delay"]

  sensitive = true
  value     = "${random_string.aks_sp_password.result}"
}
