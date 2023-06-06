"""A liveness prober dag for monitoring composer.googleapis.com/environment/healthy."""
import airflow
from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.operators.python import PythonOperator
from datetime import timedelta

default_args = {
    'start_date': airflow.utils.dates.days_ago(0),
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}

def do_something():
    print("I'm definitely doing something yo")

dag = DAG(
    'airflow_dummy_job',
    default_args=default_args,
    description='Dummy job for Airflow',
    schedule_interval='*/5 * * * *',
    max_active_runs=2,
    catchup=True,
    dagrun_timeout=timedelta(minutes=10),
)

# priority_weight has type int in Airflow DB, uses the maximum.
t1 = BashOperator(
    task_id='echo',
    bash_command='echo this is a dummy job',
    dag=dag,
    depends_on_past=False,
    do_xcom_push=False)


t2 = training_model_A = PythonOperator(
    task_id="doingsomethingelse",
    python_callable=do_something,
    dag=dag
    )


t1 >> t2