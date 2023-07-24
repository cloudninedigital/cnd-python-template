###
### COPY the desired MAIN trigger from ./modules/main_triggers below! 
###

module "gcs_folder_sync" {
  source = "./modules/gcs_folder_sync"
  name = var.bucket
  gcs_bucket_file_path = ""
  gcs_local_source_path = "../project_name/SQL/sql_scripts"
}

module "cf_http_trigger_bq_processing" {
  source = "./modules/gf_gen1_http_trigger_source_repo"
  name = "bigquery_http_function"
  description = <<EOF
This function will trigger one or multiple bigquery script based upon BigQuery Executor logic
EOF
  project = var.project
  entry_point = "main_bigquery_http_event"
  environment = {
    PROJECT           = var.project
    GCS_PROJECT       = var.project
    GCS_BUCKET_NAME   = var.bucket
    INCLUDE_VARIABLES = "false"
    SHOW_ALL_ROWS     = "false"
    ON_ERROR_CONTINUE = "false"
    EXCLUDE_TEMP_IDS  = "false"
    ENVIROMENT        = terraform.workspace
  }
}

module "workflows_cf_bigquery_trigger" {
  source = "./modules/workflows_cf_bigquery_trigger"
  name = "workflows-cf-bigquery-test"
  description = "a workflow triggered by a table update that calls the bigquery_http_function"
  project = var.project
  dataset = "some_dataset"
  table = "iets"
  workflow_template_file = "example.tftpl"
}


###
### COPY the desired MAIN trigger from ./modules/main_triggers above!
###