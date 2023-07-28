# Python code guide
This guide is not (exactly) a guide, since every data pipeline will have different needs.
Take all the instructions here-in with a critical mind. If a certain python template does not
fit your needs, then please signal this to the developers and/or adapt the code to your use-case.

All entrypoints listed below can be found in the submodule `project_name.gcp` (meaning `project_name/gcp.py` file).

## HTTP triggered Cloud Function
For HTTP triggered cloud functions, you will be using the entrypoint function `main_http_event`.

Since this entrypoint is mainly used for manual triggers, it assumes that the processing function `refresh_data` takes no arguments.
Please add any needed arguments to the `refresh_data` function and implement your functionality therein.

The `refresh_data` function lives in the submodule `project_name.base`.

## Scheduler triggered Cloud Function

For Scheduler functions, you will be using the `main_pubsub` entrypoint. This entrypoint is already implementing a basic
usage of the PubSub message that triggers the function. You can use the PubSub messages contents to further configure
your functionality.

You will notice that the `refresh_data` function is already used here, but is configured with the JSON contents of the 
PubSub message. This means that you need to adapt `refresh_data` to take such message into account.

For example, in the case where your PubSub message looks like this:
```json
{
  "target_bq_table": "<some_table_id",
  "source_gcs_bucket": "<some_bucket_id>"
}
```

Then your `refresh_data` declaration in `project_name.base` should look like this:
```python
def refresh_data(target_bq_table=None, source_gcs_bucket=None):
    if target_bq_table is None:
        target_bq_table = "<some_default_value>"
    if source_gcs_bucket is None:
        source_gcs_bucket = "<another_default_value>"

    # ... your functionality here
```

## BigQuery event triggered Cloud Function
For using Bigquery events, you must use the `main_bigquery_event` entrypoint.

### Executing SQL statements when a BigQuery table is updated
The function `main_bigquery_event` is already populated with code that executes of SQL statements on-demand.
Usually you want to execute an SQL statement as a result of a table being updated.

To that effect, you should take these two steps:
1. Declare your SQL statement in a file with the `.sql` extension. Save it under `project_name/SQL/sql_scripts`.
2. Update the file `project_name/SQL/table_script_lookup.json` and fill it with a similar content to:
```json
{
  "<your_table_id>": ["my_script_name.sql"]
}
```

 **Note** Only if you save yours scripts in `./project_name/SQL/sql_scripts` can you declare them without the full path.
 Otherwise your use the full path in the JSON config above:
 ````json
{
  "<your_table_id>": ["./project_name/SQL/sql_scripts/<my_script_name>.sql"]
}
````

Note that you can declare more than one script to run in sequence for a given table ID that features in a BigQuery event.

### Executing regular python code when a BigQuery table is updated

In order to execute code that cannot be expressed in an SQL statement, then you can still use the `main_bigquery_event`
entrypoint, but you will change the last line of the function to whatever functionality you want to implement. The last
line is the one that right now executes SQL statements and it looks like this:
```python
    execute_query_script(f'{dataset}.{table}')
```

## Cloud Storage event triggered Cloud Function
### When to use
It is pretty common place to need to react to new files being created in a Google Storage bucket.
Most often, you want to react to such files and then process them in python before exporting the processed data to BigQuery.

### How to use
This functionality uses the entrypoint `main_gcs_event`, which already has a few things implemented:
* Extraction of a file path from the GCS event container
* Passing that file path to the function `export_bucket_file_to_bq`

So in order for you to use this template, you need to modify the function `export_bucket_file_to_bq` so that it implements
your functionality.