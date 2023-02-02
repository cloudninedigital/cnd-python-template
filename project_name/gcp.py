import functions_framework
from project_name.base import export_bucket_file_to_bq, refresh_data_from_api


@functions_framework.cloud_event
def main_cloud_event(cloud_event):
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
        refresh_data_from_api()
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
    refresh_data_from_api(**json_config)

    return "Processing was successful"


@functions_framework.cloud_event
def main_bigquery_event(cloud_event):

    data = cloud_event.data
    bucket = data["bucket"]
    file_name = data["name"]
    print(f"Bucket: {bucket}")
    print(f"File: {file_name}")

    # Implement processing of file here
    file_path = f"gs://{bucket}/{file_name}"
    export_bucket_file_to_bq(file_path)
