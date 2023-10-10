output "terraform_state_bucket" {
  value = google_storage_bucket.tfstate.name
}

output "terraform_service_account" {
  value = google_service_account.terraform_agent.email
}
