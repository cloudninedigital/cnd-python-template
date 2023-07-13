import json
import os
import re


class BigQueryExecutorTableConfig:
    def __init__(self, config, environment=None):
        self._environment = environment or os.environ.get("ENVIRONMENT")
        self._config = config
        if self._environment is not None:
            self.replace_environment()

    def replace_environment(self):
        """Replace environment placeholder in table name with environment name"""
        if isinstance(self._config, list):
            for i, table in enumerate(self._config):
                self._config[i] = self._config[i].format(env=self._environment)
        else:
            for i, table in enumerate(self._config["scripts"]):
                self._config["scripts"][i] = self._config["scripts"][i].format(
                    env=self._environment
                )
            if self.variables is not None:
                for k, v in self.variables.items():
                    self.variables[k] = v.format(env=self._environment)

    @property
    def scripts(self):
        if isinstance(self._config, list):
            return self._config
        else:
            return self._config["scripts"]

    @property
    def variables(self):
        if isinstance(self._config, list):
            return None
        else:
            return self._config["variables"]


class BigQueryExecutorConfig:
    def __init__(self, config):
        self._config = config

    def __getitem__(self, table):
        """Returns BigQueryExecutorTableConfig for specified table pattern

        Args:
            table: Table name or pattern that matches a config table name

        Returns:
            BigQueryExecutorTableConfig
        """

        for k in self._config:
            # TODO allow for regex matching
            # Here we test for a partial match of the table name, so accommodate for triggering on sharded tables
            if k not in table:
                continue
            return BigQueryExecutorTableConfig(self._config[k])

    @classmethod
    def from_string(cls, serialized_config):
        """Returns BigQueryExecutorConfig from a JSON string

        Args:
            serialized_config: JSON string

        Returns:
            BigQueryExecutorConfig
        """
        return cls(json.loads(serialized_config))

    @classmethod
    def from_file(cls, config_file):
        """Returns BigQueryExecutorConfig from a JSON file

        Args:
            config_file: JSON file

        Returns:
            BigQueryExecutorConfig
        """
        with open(config_file) as f:
            return cls(json.load(f))

    @classmethod
    def from_gcs(cls, file_name):
        """Returns BigQueryExecutorConfig from a JSON file in Google Cloud Storage

        Bucket name and credentials are taken from environment variables.

        Args:
            file_name: JSON file name

        Returns:
            BigQueryExecutorConfig
        """
        from cnd_tools.cloudstorage.google_storage import GoogleCloudStorage

        gcs = GoogleCloudStorage()
        serialized_config = gcs.download_file(file_name)
        return cls.from_string(serialized_config)


class NoDatasetUpdatedException(Exception):
    pass


def get_dataset_from_cloud_event(cloud_event):
    """Get the dataset and table names from the cloud event

    Args:
        cloud_event: Dictionary containing the cloud event specification. See
    https://cloud.google.com/eventarc/docs/workflows/cloudevents for more information.

    Returns:
        dataset: Dataset name
        table: Table name
    """
    data = cloud_event.data
    print(data)

    if (
        not "metadata" in data["protoPayload"]
        or not "tableDataChange" in data["protoPayload"]["metadata"].keys()
        or not "insertedRowsCount"
        in data["protoPayload"]["metadata"]["tableDataChange"].keys()
        or int(data["protoPayload"]["metadata"]["tableDataChange"]["insertedRowsCount"])
        < 1
    ):
        raise NoDatasetUpdatedException(
            "No rows were inserted or no dataset was found."
        )

    # this seems unsafe but the function wouldn't have triggered if this pattern did not exist
    dataset = re.search(
        r"datasets\/(.*)\/tables", data["protoPayload"]["resourceName"]
    )[1]
    table = re.search(r"/tables/(.*)", data["protoPayload"]["resourceName"])[1]
    return dataset, table


