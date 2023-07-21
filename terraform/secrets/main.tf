resource "google_project_service" "secretmanager" {
  provider = google-beta
  service  = "secretmanager.googleapis.com"
  project = var.project
}

module "secret-manager" {
  source  = "GoogleCloudPlatform/secret-manager/google"
  version = "~> 0.1"
  project_id = var.project
  secrets = var.secrets
  depends_on = [ google_project_service.secretmanager ]
}