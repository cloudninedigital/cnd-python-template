resource "google_storage_bucket" "tfstate" {
  name          = "project_name-${var.project}-tfstate"
  project       = var.project
  force_destroy = false
  location      = "EU"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}

resource "google_project_service" "cloud_resource_manager" {
  project            = var.project
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}