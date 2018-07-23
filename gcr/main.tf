variable "google_project_id" {}

data "google_container_registry_repository" "registry" {
  project = "${var.google_project_id}"
}

resource "google_service_account" "registry_user" {
  account_id   = "registryuser"
  display_name = "Registry User"
  project      = "${var.google_project_id}"
}

resource "google_project_iam_member" "storage_admin" {
  project = "${var.google_project_id}"
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.registry_user.email}"
}

resource "google_project_iam_member" "object_admin" {
  project = "${var.google_project_id}"
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.registry_user.email}"
}

resource "google_service_account_key" "access_key" {
  service_account_id = "${google_service_account.registry_user.name}"
}

output "url" {
  value = "${data.google_container_registry_repository.registry.repository_url}"
}

output "credentials" {
  sensitive = true
  value     = "${base64decode(google_service_account_key.access_key.private_key)}"
}
