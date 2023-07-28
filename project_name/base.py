import json
from .SQL.bigquery_executor import BigQueryScriptExecutor
from cnd_tools.cloudstorage.google_storage import GoogleCloudStorage

def export_bucket_file_to_bq(file_path):
    pass


def refresh_data(*args, **kwargs):
    pass


def execute_query_script(table):
    gcs = GoogleCloudStorage()
    table_script_lookup = json.loads(gcs.download_file('table_script_lookup.json'))
    for k in table_script_lookup.keys():
        if not k in table:        
            continue
        for sfl in table_script_lookup[k]:
            path = "/".join(sfl.split("/")[:-1])
            gcs.download_file(sfl, f'./{path}')
            bq = BigQueryScriptExecutor(script_file_location=f'./{sfl}', table=table)
            bq.execute_script_file()