terraform {
  backend "gcs" {
    bucket = "<same_name_as_declared_in_remote_state>"
    prefix = "terraform/state"
  }
}
