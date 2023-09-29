output "terraform_state_bucket" {
  value = google_storage_bucket.tfstate.name
}
