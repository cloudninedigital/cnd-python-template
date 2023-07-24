import logging
import os

import functions_framework

from project_name.SQL.bigquery_executor import BigQueryScriptExecutor
from project_name.base import export_bucket_file_to_bq, refresh_data
from project_name.bq_executor import BigQueryExecutorConfig
from cnd_tools.cloudstorage.google_storage import GoogleCloudStorage


@functions_framework.cloud_event
def main_gcs_event(cloud_event):
    data = cloud_event.data
    bucket = data["bucket"]
    file_name = data["name"]
    print(f"Bucket: {bucket}")
    print(f"File: {file_name}")

    # Implement processing of file here
    file_path = f"gs://{bucket}/{file_name}"
    export_bucket_file_to_bq(file_path)


@functions_framework.http
def main_http_event(request):
    try:
        refresh_data()
    except Exception:
        # TODO Improve error reporting
        return "Processing was unsuccessful", 500

    return "Processing was successful", 200


@functions_framework.cloud_event
def main_pubsub(cloud_event):
    import base64
    import json
    # This assumes that the message coming through is a JSON serialized string
    config = base64.b64decode(cloud_event.data["message"]["data"]).decode()
    print(f"Running Cloud Function with the following config {config}.")

    json_config = json.loads(config)
    # We let any exception through
    refresh_data(**json_config)

    return "Processing was successful"

@functions_framework.http
def main_bigquery_http_event(request):
    request_json = request.get_json(silent=True)
    print(request_json)
    table_updated = request_json.get('table_updated')
    if not table_updated:
        return main_bigquery_event(request_json.get('cf_event'))
    execute_query_script(table_updated)
    return "OK"

@functions_framework.cloud_event
def main_bigquery_event(cloud_event):
    from .bq_executor import get_dataset_from_cloud_event, NoDatasetUpdatedException

    try:
        dataset, table = get_dataset_from_cloud_event(cloud_event)
    except NoDatasetUpdatedException:
        logging.warning("No dataset was updated or no rows were updated. Nothing to do.")
        return "not_created_inserted"
    # Implement processing of file here
    execute_query_script(f'{dataset}.{table}')
    return "OK"


# TODO make this function also be able to execute a local config and script file
def execute_query_script(table, config_file_location=None):
    """
    Download the config file from the location specified in the environment variable CONFIG_FILE_LOCATION
    and execute the script file specified in the config file for the table specified in the function call.

    Args:
        table: Table name to execute the script for (should be present in config file)
        config_file_location: Config file location (can be set through environment variable CONFIG_FILE_LOCATION).
    Defaults to "table_script_lookup.json"
    """
    gcs = GoogleCloudStorage()

    config_file_location = config_file_location or os.getenv("CONFIG_FILE_LOCATION")
    if config_file_location is None:
        config_file_location = "table_script_lookup.json"

    executor_config = BigQueryExecutorConfig.from_gcs(config_file_location)
    table_config = executor_config[table]
    scripts = table_config.scripts
    variables = table_config.variables
    tables = table_config.tables
    for sfl in scripts:
        # TODO use pathlib instead
        path = "/".join(sfl.split("/")[:-1])
        gcs.download_file(sfl, f"./{path}")
        bq = BigQueryScriptExecutor(
            script_file_location=f"./{sfl}",
            table=table,
            variables=variables,
            table_markers=tables
        )
        bq.execute_script_file()