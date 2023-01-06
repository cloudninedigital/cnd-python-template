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

