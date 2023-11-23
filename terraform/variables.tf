variable "project" {
  description = "Project ID"
  type        = string
}

variable "application_name" {
  description = "Name of the application"
  type        = string
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