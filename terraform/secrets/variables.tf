variable "project" {
  description = "Project ID"
  type        = string
}

variable "secrets" {
  description = "list of secrets, each containing the keys name (string), automatic_replication (boolean) and secret_data (string)"
  type        = list(object({
                    name         = string
                    automatic_replication = bool
                    secret_data = string
                }))
  default     = [{name: "tf-test-secret", automatic_replication: true, secret_data: "thisisasecret"}]
}
