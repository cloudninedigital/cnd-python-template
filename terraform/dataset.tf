# resource "google_bigquery_dataset" "my_dataset" {
#   dataset_id = "some_dataset"
#   friendly_name = "optional"
#   description = "Describe your dataset here"
#   location = var.region
# }

# resource "google_bigquery_table" "orders_table" {
#   dataset_id = google_bigquery_dataset.my_dataset.dataset_id
#   table_id   = "my_table"

#   time_partitioning {
#     type = "DAY" # Supported types are DAY, HOUR, MONTH, and YEAR
#     field = "date"
#     # expiration_ms =
#     # require_partition_filter =
#   }

#   clustering = ["brand"] # Up to 4

#   schema = file("${path.module}/../project_name/schemas/my_table_schema.json")
# }
