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


def main_http_event(request):

    try:
        refresh_data_from_api()
    except Exception:
        return "Processing was unsuccessful"

    return "Processing was successful"


@functions_framework.cloud_event
def main_bigquery_event(cloud_event):

    data = cloud_event.data
    print(data)
    # table = data["table"]
    # print(f"Table: {table}")

    # Implement processing of file here
    # export_bucket_file_to_bq(table)