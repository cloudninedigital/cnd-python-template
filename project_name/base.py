import json
from .SQL.bigquery_executor import BigQueryScriptExecutor

import json
from .SQL.bigquery_executor import BigQueryScriptExecutor
from .utils import resolve_sql_script_location


def export_bucket_file_to_bq(file_path):
    pass


def refresh_data(*args, **kwargs):
    pass


def execute_query_script(table):
    with open('./project_name/SQL/table_script_lookup.json') as _file:
        table_script_lookup = json.load(_file)
    for sfl in table_script_lookup[table]:
        sfl = resolve_sql_script_location(sfl)
        bq = BigQueryScriptExecutor(
            script_file_location=resolve_sql_script_location(sfl)
        )
        bq.execute_script_file()
