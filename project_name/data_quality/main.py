import functions_framework
import pandas as pd
import os
from cnd_tools.database.data_quality.bigquery_data_quality import BQDataQualityChecker
from cnd_tools.database.bigquery import BigQueryConnection

@functions_framework.cloud_event
def main_scheduled_data_quality_check(cloud_event):
    from pathlib import Path
    config_path = Path(__file__).parent / os.environ.get("CONFIGURATION_FILE_NAME", "configuration.json")
    dq = BQDataQualityChecker(config_path=config_path)
    results = dq.check_all_tables(write_results=False)
    bq = BigQueryConnection(project=os.environ.get("WRITE_PROJECT"))
    bq.put_data(pd.DataFrame(results),os.environ.get("WRITE_DATASET"), os.environ.get("WRITE_TABLE"), create_if_not_exists=True)
    return "all checks performed and written"