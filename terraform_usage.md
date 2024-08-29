# First configuration steps

Before we begin choosing what kind of deployment we want to make, let's first start
by configuring our project and repo names:
* Open a new file called `terraform/terraform.tfvars`
* Add the following contents:
````terraform
project = "Project ID of your GCP project (CHANGE ME)"
application_name = "Name you want to give your Cloud function (CHANGE ME, no spaces)"
source_repo_name = "Google Cloud source repo name (CHANGE ME, no spaces)"
````
Review all the values so that they make sense for your project, application and repo hosting.

> **Note** This already assumes that your link between the GitHub repo and Google Cloud Source is established.
> If that is not the case please visit [Link GitHub repo into a Google Cloud Source repo](./README.md#52-link-github-repo-into-a-google-cloud-source-repo).

> **IMPORTANT:** The modules currently can be found within the [CND Terraform repository on GitHub](https://github.com/cloudninedigital/cnd-terraform). For more information on extracting a module from GitHub, please visit the [Terraform documentation on module sources](https://developer.hashicorp.com/terraform/language/modules/sources#github). You can also find guidance on [selecting a module's revision](https://developer.hashicorp.com/terraform/language/modules/sources#selecting-a-revision) and [working with subdirectories](https://developer.hashicorp.com/terraform/language/modules/sources#selecting-a-revision).

# Choosing and configuring your Terraform configuration

The Terraform configurations present take care of activating all the necessary services
that you will need, as well as permissions and service account settings in GCP.

Below you will find a few sections describing specific deployments, when to use them, and how to configure them:
* [HTTP triggered Cloud Function](#http-triggered-cloud-function)
* [Scheduler triggered Cloud Function](#scheduler-triggered-cloud-function)
* [BigQuery event triggered Cloud Function](#bigquery-event-triggered-cloud-function)
* [Cloud Storage event triggered Cloud Function](#cloud-storage-event-triggered-cloud-function)

## HTTP triggered Cloud Function
### When to use
HTTP triggered functions should be used when it is necessary that someone is able to manually trigger this function to run.
For example, this is quite useful to allow someone to create a "button" in a front-end or Google-Sheets that invokes this function.

> See documentation about [GoogleSheets integration](https://wiki.cloudninedigital.nl/en/Processing-and-Delivery/Google-Cloud/Google-Sheets-Integrations).

### How to use
1. Copy the contents of `terraform/modules/main_triggers/main_http_trigger_gcf.tf` into your `terraform/main.tf` file.
2. Adapt the environment variables to your needs. If you do not need environment variables (are you sure :smirk:), make
sure to delete the whole `environment` variable from the configuration.

## Scheduler triggered Cloud Function
## When to use
This configuration is mostly used when you need to run a Cloud Function on a certain schedule (for example every night at 02:00).

## How to use
1. Copy the contents of `terraform/modules/main_triggers/main_scheduled_trigger_gcf.tf` into your `terraform/main.tf` file.
2. Adapt the environment variables to your needs. If you do not need environment variables (are you sure :smirk:), make
   sure to delete the whole `environment` variable from the configuration.

## BigQuery event triggered Cloud Function

## When to use
This configuration is particularly interesting if you want your Cloud Function to run every time a certain BigQuery event
happens (for example a table gets updated with new data).

## How to use
1. Copy the contents of `terraform/modules/main_triggers/main_bq_trigger_gcf.tf` into your `terraform/main.tf` file.
2. Adapt the environment variables to your needs. If you do not need environment variables (are you sure :smirk:), make
   sure to delete the whole `environment` variable from the configuration.
   * show_all_rows: boolean, default=False. determines if select queries (so not create/update statements) should yield 
   all results. By default you'll only see the first 10 rows of the select query. 
   * on_error_continue: boolean, default=`false`. determines if the script should continue after an error has occured in 
   one of the queries. 
   * exclude_temp_ids: boolean, default=`false`. Determines if the addition of a random_id to tables created in dataset 
   'temp' should be added or not. These temp_ids are added to avoid collision of commonly named temp tables that might run at the same time (such as temp.products for example). 
   * include_variables: boolean, default=`false`. Determines if the variable set functionality needs to be used or not. If 
   `true`, variables can be set by adding a select query formatted like: `--set_variable--example_variable_name --set_variable --
   select value from example.table' and can used in queries like 'select '$$example_variable_name$$'
   
## Cloud Storage event triggered Cloud Function
## When to use
You should use this configuration when you need your Function to act on a Google Cloud Storage event (most often that is
the creation/upload of a new file).

## How to use
1. Copy the contents of `terraform/modules/main_triggers/main_bucket_trigger_gcf.tf` into your `terraform/main.tf` file.
2. Depending on whether you want to create a new bucket or not, follow one of the options below:
   2.a. If you want to create a bucket, make sure to name the resource `landing_bucket` according to your preference.
   2.b. If you already have a bucket that you intend to use, then you can delete the `landing_bucket` resource. Make sure
   to update the setting `trigger_resource` in the `cs_gcs_to_bq` resource to the name of the bucket you need to use (
   exclude the `gcs://` part of the path from this name).

For the next step, follow the [HTTP triggered Functions](./python_usage.md#cloud-storage-event-triggered-cloud-function)
