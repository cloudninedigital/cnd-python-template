locals {
  bootstrap_services = {
    cloudbuild = "cloudbuild.googleapis.com",
    cloudresourcemanager = "cloudresourcemanager.googleapis.com",
    iam = "iam.googleapis.com",
    serviceusage = "serviceusage.googleapis.com"
  }
  terraform_permissions = {
    editor = "roles/editor",
    security_admin = "roles/iam.securityAdmin",
  }
}

resource "google_project_service" "services" {
  for_each = local.bootstrap_services
  project  = var.project
  provider           = google-beta
  service            = each.value
  disable_on_destroy = false
}

resource "google_service_account" "terraform_agent" {
  account_id   = "terraform-agent"
  display_name = "Terraform Agent"
  project      = var.project
}

resource "google_project_iam_member" "terraform_permissions" {
    for_each = local.terraform_permissions
  member  = "serviceAccount:${google_service_account.terraform_agent.email}"
  project = var.project
  role    = each.value
}