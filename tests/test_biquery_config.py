import pytest

from project_name.bq_executor import BigQueryExecutorConfig, BigQueryExecutorTableConfig


def test_updated_config_schema():
    config = BigQueryExecutorConfig.from_string(
        """
        {
           "dataset1.table1": {
                "scripts": [
                    "script1.sql",
                    "script2.sql"
                ],
                "variables": {
                    "variable1": "value1",
                    "variable2": "value2"
                }
            },
            "dataset2.table2": {
                "scripts": [
                    "script3.sql",
                    "script4.sql"
                ],
                "variables": {
                    "variable3": "value3",
                    "variable4": "value4"
                }
            }
        }
        """
    )

    assert config["dataset1.table1"].scripts == ["script1.sql", "script2.sql"]
    assert config["dataset1.table1"].variables == {"variable1": "value1", "variable2": "value2"}
    assert config["dataset2.table2"].scripts == ["script3.sql", "script4.sql"]
    assert config["dataset2.table2"].variables == {"variable3": "value3", "variable4": "value4"}
    assert config["dataset2.table2"].tables is None


def test_updated_config_schema_without_variables():
    config = BigQueryExecutorConfig.from_string(
        """
        {
           "dataset1.table1": {
                "scripts": [
                    "script1.sql",
                    "script2.sql"
                ]
            },
            "dataset2.table2": {
                "scripts": [
                    "script3.sql",
                    "script4.sql"
                ]
            }
        }
        """
    )

    assert config["dataset1.table1"].scripts == ["script1.sql", "script2.sql"]
    assert config["dataset1.table1"].variables is None
    assert config["dataset1.table1"].tables is None
    assert config["dataset2.table2"].scripts == ["script3.sql", "script4.sql"]
    assert config["dataset2.table2"].variables is None
    assert config["dataset2.table2"].tables is None


def test_basic_schema():
    config = BigQueryExecutorConfig.from_string(
        """
        {
           "dataset1.table1": [
                "script1.sql",
                "script2.sql"
            ],
            "dataset2.table2": [
                "script3.sql",
                "script4.sql"
            ]
        }
        """
    )

    assert config["dataset1.table1"].scripts == ["script1.sql", "script2.sql"]
    assert config["dataset1.table1"].variables is None
    assert config["dataset2.table2"].scripts == ["script3.sql", "script4.sql"]
    assert config["dataset2.table2"].variables is None
    assert config["dataset2.table2"].tables is None


@pytest.fixture
def basic_config_file(tmpdir):
    config_file = tmpdir.join("config.json")
    config_file.write(
        """
        {
           "dataset1.table1": [
                "script1.sql",
                "script2.sql"
            ],
            "dataset2.table2": [
                "script3.sql",
                "script4.sql"
            ]
        }
        """
    )
    return str(config_file)


def test_basic_schema_from_file(basic_config_file):
    config = BigQueryExecutorConfig.from_file(basic_config_file)

    assert config["dataset1.table1"].scripts == ["script1.sql", "script2.sql"]
    assert config["dataset1.table1"].variables is None
    assert config["dataset2.table2"].scripts == ["script3.sql", "script4.sql"]
    assert config["dataset2.table2"].variables is None


@pytest.fixture
def upgraded_config_file(tmpdir):
    config_file = tmpdir.join("config.json")
    config_file.write(
        """
        {
           "dataset1.table1": {
                "scripts": [
                    "script1.sql",
                    "script2.sql"
                ],
                "variables": {
                    "variable1": "value1",
                    "variable2": "value2"
                }
            },
            "dataset2.table2": {
                "scripts": [
                    "script3.sql",
                    "script4.sql"
                ],
                "variables": {
                    "variable3": "value3",
                    "variable4": "value4"
                }
            }
        }
        """
    )
    return str(config_file)


def test_upgraded_config_file(upgraded_config_file):
    config = BigQueryExecutorConfig.from_file(upgraded_config_file)

    assert config["dataset1.table1"].scripts == ["script1.sql", "script2.sql"]
    assert config["dataset1.table1"].variables == {"variable1": "value1", "variable2": "value2"}
    assert config["dataset2.table2"].scripts == ["script3.sql", "script4.sql"]
    assert config["dataset2.table2"].variables == {"variable3": "value3", "variable4": "value4"}


def test_environment_substution_in_sql_script_file_names():
    config = BigQueryExecutorConfig.from_string(
        """
        {
           "dataset1.table1": [
                "script1_{env}.sql",
                "script2_{env}.sql"
            ],
            "dataset2.table2": [
                "script3_{env}.sql",
                "script4_{env}.sql"
            ]
        }
        """,
        environment="dev"
    )

    assert config["dataset1.table1"].scripts == ["script1_dev.sql", "script2_dev.sql"]
    assert config["dataset1.table1"].variables is None
    assert config["dataset2.table2"].scripts == ["script3_dev.sql", "script4_dev.sql"]
    assert config["dataset2.table2"].variables is None


def test_environment_substitution_in_variable_values():
    config = BigQueryExecutorConfig.from_string(
        """
        {
           "dataset1.table1": {
                "scripts": [
                    "script1.sql",
                    "script2.sql"
                ],
                "variables": {
                    "variable1": "value1_{env}",
                    "variable2": "value2_{env}"
                }
            },
            "dataset2.table2": {
                "scripts": [
                    "script3.sql",
                    "script4.sql"
                ],
                "variables": {
                    "variable3": "value3_{env}",
                    "variable4": "value4_{env}"
                }
            }
        }
        """,
        environment="dev"
    )

    assert config["dataset1.table1"].scripts == ["script1.sql", "script2.sql"]
    assert config["dataset1.table1"].variables == {"variable1": "value1_dev", "variable2": "value2_dev"}
    assert config["dataset2.table2"].scripts == ["script3.sql", "script4.sql"]
    assert config["dataset2.table2"].variables == {"variable3": "value3_dev", "variable4": "value4_dev"}


def test_environment_substitution_in_table_names():
    config = BigQueryExecutorConfig.from_string(
        """
        {
           "dataset1.table1_{env}": [
                "script1.sql",
                "script2.sql"
            ],
            "dataset2.table2_{env}": [
                "script3.sql",
                "script4.sql"
            ]
        }
        """,
        environment="dev"
    )

    assert config["dataset1.table1_dev"].scripts == ["script1.sql", "script2.sql"]
    assert config["dataset1.table1_dev"].variables is None
    assert config["dataset2.table2_dev"].scripts == ["script3.sql", "script4.sql"]
    assert config["dataset2.table2_dev"].variables is None


def test_upgraded_schema_with_tables():
    config = BigQueryExecutorConfig.from_string(
        """
        {
              "dataset1.table1": {
                "scripts": [
                    "script1.sql",
                    "script2.sql"
                ],
                "variables": {
                    "variable1": "value1",
                    "variable2": "value2"
                },
                "tables": [
                    "dataset1.table1",
                    "dataset2.table2"
                ]
            },
            "dataset2.table2": {
                "scripts": [
                    "script3.sql",
                    "script4.sql"
                ],
                "variables": {
                    "variable3": "value3",
                    "variable4": "value4"
                },
                "tables": [
                    "dataset1.table1",
                    "dataset2.table2"
                ]
            }
        }
        """
    )

    assert config["dataset1.table1"].scripts == ["script1.sql", "script2.sql"]
    assert config["dataset1.table1"].variables == {"variable1": "value1", "variable2": "value2"}
    assert config["dataset1.table1"].tables == ["dataset1.table1", "dataset2.table2"]
    assert config["dataset2.table2"].scripts == ["script3.sql", "script4.sql"]
    assert config["dataset2.table2"].variables == {"variable3": "value3", "variable4": "value4"}
    assert config["dataset2.table2"].tables == ["dataset1.table1", "dataset2.table2"]
