variable "application_name" {
  description = "Name of application"
  type = string
  default = "bq-executor"
}

variable "project" {
  description = "Project ID"
  type        = string
  default     = "emerald-eon-368712"
}

variable "region" {
  description = "Region of most of the resources"
  type        = string
  default     = "europe-west4"
}

variable "zone" {
  description = "Zone of most of the resources"
  default     = "europe-west4-c"
}

variable "functions_region" {
  description = "Region where Cloud functions are deployed."
  default     = "europe-west1"
}

variable "source_repo_name" {
  description = "Name of the repository holding the source code in Cloud Source."
  default = "github_cloudninedigital_cnd-etl-template"
}

variable "source_repo_branch" {
  description = "Branch name containing code to be deployed."
  type = string
  default = "main"
}