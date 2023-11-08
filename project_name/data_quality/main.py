import functions_framework
import pandas as pd
import os
from cnd_tools.database.data_quality.bq_data_quality_checker import BQDataQualityChecker
from cnd_tools.database.bigquery import BigQueryConnection

@functions_framework.cloud_event
def main_scheduled_data_quality_check(cloud_event):
    dq = BQDataQualityChecker(config_path="./configuration.json")
    results = dq.check_all_tables(write_results=False)
    bq = BigQueryConnection(project=os.environ.get("WRITE_PROJECT"))
    bq.put_data(pd.DataFrame(results),os.environ.get("WRITE_DATASET"), os.environ.get("WRITE_TABLE"), create_if_not_exists=True)
    return "all checks performed and written"