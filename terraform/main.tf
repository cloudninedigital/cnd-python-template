###
### COPY the desired MAIN trigger from ./modules/main_triggers below! 
###

# module "gcs_folder_sync" {
#   source                = "./modules/gcs_folder_sync"
#   name                  = "${var.application_name}-bqexecutor-sync"
#   gcs_bucket_file_path  = ""
#   gcs_local_source_path = "../project_name/SQL/sql_scripts"
# }

# module "workflows_cf_main_trigger" {
#   source = "./modules/workflows_cf"
#   name = "workflows-cf-bigquery-test-${terraform.workspace}"
#   description = "a workflow triggered by a table update that calls the bigquery_http_function"
#   project = var.project
#   dataset = "some_dataset"
#   table = "iets"
#   trigger_type = "schedule"
#   schedule = "*/2 * * * *"
#   cloudfunctions = [{
#     "name": "bigquery_http_function",
#     "table_updated": "some_dataset.iets"
#   },{
#     "name": "bigquery_http_function",
#     "table_updated": "some_dataset.nogiets"
#   }]
#   functions_region = "europe-west1"
#   alert_on_failure = true
# }


###
### COPY the desired MAIN trigger from ./modules/main_triggers above!
###