import json
from .SQL.bigquery_executor import BigQueryScriptExecutor

def export_bucket_file_to_bq(file_path):
    pass


def refresh_data_from_api(*args, **kwargs):
    pass


def execute_query_script(table):
    with open('SQL/table_script_lookup.json') as _file:
        table_script_lookup = json.load(_file)
    for sfl in table_script_lookup[table]:        
        bq = BigQueryScriptExecutor(script_file_location=sfl)
        bq.execute_query_script()
