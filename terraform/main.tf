###
### COPY the desired MAIN trigger from ./modules/main_triggers below! 
###

module "cgf_bigquery" {
  source = "./modules/gf_gen2_bigquery_trigger_source_repo"
  name = var.application_name
  description = <<EOF
  This function will trigger when a bigquery table create or delete has happened
EOF
  project = var.project
  entry_point = "main_bigquery_event"
  environment = {
    PROJECT=var.project
    BUCKET_NAME=var.bucket
    INCLUDE_VARIABLES="false"
    SHOW_ALL_ROWS="false"
    ON_ERROR_CONTINUE="false"
    EXCLUDE_TEMP_IDS="false"
  }
}




###
### COPY the desired MAIN trigger from ./modules/main_triggers above!
###