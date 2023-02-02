import argparse
from google.cloud import bigquery
from google.oauth2 import service_account
import os
import random
import json
import re
import logging


logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', encoding='utf-8', level=logging.INFO)

class BigQueryScriptExecutor:
    """class to execute bigquery scripts. 

        Class Arguments: 
        * project: string, required. project in which to make the query statements.
        * script_file_location: string, required. The location where the script that is to be executed resides.
        * credentials: google oauth2 Credentials object, optional. Use this if you want to authenticate with your own credentials object. By default the class uses the 'GOOGLE_APPLICATION_CREDENTIALS' environment variable or a standard login created by `gcloud auth application-default login`. This default is a standard from google cloud.
        * show_all_rows: boolean, default=False. determines if select queries (so not create/update statements) should yield all results. By default you'll only see the first 10 rows of the select query. 
        * on_error_continue: boolean, default=False. determines if the script should continue after an error has occured in one of the queries. 
        * exclude_temp_ids: boolean, default=False. Determines if the addition of a random_id to tables created in dataset 'temp' should be added or not. These temp_ids are added to avoid collision of commonly named temp tables that might run at the same time (such as temp.products for example). 
        * include_variables: boolean, defualt=False. Determines if the variable set functionality needs to be used or not. if True, variables can be set by adding a select query formatted like: '--set_variable--example_variable_name--set_variable-- select value from example.table' and can used in queries like 'select '$$example_variable_name$$'
    

        example usage:
        bq = BigQueryScriptExecutor(project="mygreatproject", script_file_location="./sql_scripts/example.sql")
    
        Example usage of calling the script itself:
        python3 bigquery-executor.py --project="cloudnine-digital" \
        --script_file_location="./sql-scripts/example.sql"

        More extensive argument options are shown in the main function (mostly same as class options, with the exception that a )
    """
    def __init__(self, project: str = None, script_file_location: str = None, credentials = None,
                 show_all_rows: bool =False, on_error_continue: bool =False, exclude_temp_ids: bool =False, include_variables: bool =False):
        self.project = project or os.environ.get('project')
        self.script_file_location = script_file_location or os.environ.get('script_file_location')
        self.show_all_rows = show_all_rows or os.getenv('script_file_location', '').lower() == 'true'
        self.on_error_continue = on_error_continue or os.getenv('on_error_continue', '').lower() == 'true'
        self.exclude_temp_ids = exclude_temp_ids or os.getenv('exclude_temp_ids', '').lower() == 'true'
        self.include_variables = include_variables or os.getenv('include_variables', '').lower() == 'true'
        self.variables = {}
        self._authenticate(project, credentials)

    def _authenticate(self, project, credentials=None):
        if credentials is not None:
            self.client = bigquery.Client(project = project, credentials=credentials)
            return
        self.client = bigquery.Client(project = project)

    def execute_script_file(self):
        limit = 10
        temp_id = random.randint(1, 100000)
        if self.exclude_temp_ids:
            temp_id = ""

        with open(self.script_file_location, encoding="ISO-8859-1") as file:
            queries = re.split(r'\;(?!\-\-donotsplit)',file.read())

        for query in queries:
            if query.strip() == "":
                logging.info(f"query {queries.index(query) + 1} of {len(queries)} is empty")
                continue

            query_temp_id = query.replace("temp.", f"temp.{temp_id}")
            for var in self.variables.keys():
                query_temp_id = query_temp_id.replace(f"$${var}$$", self.variables[var])
            logging.info(f"executing query {queries.index(query) + 1}: {query_temp_id}")
            query_job = self.client.query(
                (query_temp_id),
                project=self.project
            )
            try:
                result = query_job.result()
                logging.info(f"query {queries.index(query) + 1} of {len(queries)} succeeded")
                if self.show_all_rows:
                    limit = result.total_rows
                i = 0
                for row in result:
                    if i >= limit:
                        break
                    print(row)
                    i += 1
                if self.include_variables and "--set_variable--" in query and query.strip().index("--set_variable--") == 0:
                    logging.info(f"variable being set: {query.strip().split('--set_variable--')[1]} --> {row[0]}")
                    varname = query.strip().split("--set_variable--")[1]
                    self.variables[varname] = row[0]

            except Exception as e:
                logging.warn(f"exception: {e} \nin query: {query_temp_id}")
                if not self.on_error_continue:
                    raise Exception(e)

        logging.info("all queries have been executed")



def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--project', type=str, required=False)
    parser.add_argument('--script_file_location', type=str, required=False)
    parser.add_argument('--show_all_rows', type=bool, required=False, default=False)
    parser.add_argument('--on_error_continue', type=bool, required=False, default=False)
    parser.add_argument('--exclude_temp_ids', type=bool, required=False, default=False)
    parser.add_argument('--include_variables', type=bool, required=False, default=False)
    parser.add_argument('--service_account_credentials_file', type=str, required=False, default=None)
    credentials = None
    flags, _ = parser.parse_known_args()

    if flags.service_account_credentials_file is not None:
        with open(flags.service_account_credentials_file, 'r') as _file:
            BQ_CONN_INFO = json.loads(_file.read())
        credentials = service_account.Credentials.from_service_account_info(BQ_CONN_INFO)
    bq = BigQueryScriptExecutor(flags.project, flags.script_file_location,
                          show_all_rows=flags.show_all_rows, on_error_continue=flags.on_error_continue
                          , exclude_temp_ids=flags.exclude_temp_ids, include_variables=flags.include_variables)
    bq.execute_script_file()


if __name__ == '__main__':
    main()
