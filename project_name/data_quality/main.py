import functions_framework
from utils import read_configurations
from cnd_tools.database.bq_data_quality_checker import BQDataQualityChecker

@functions_framework.cloud_event
def main_scheduled_data_quality_check(cloud_event):
    config = read_configurations()
    check = BQDataQualityChecker(config)
    check.check_it()
    return "Processing was successful"