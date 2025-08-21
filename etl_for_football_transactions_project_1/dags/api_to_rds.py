from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator

from ingestion.extract_2 import get_results
from ingestion.load_rds import load_to_rds

default_args = {
    "owner": "zainab",
    "depends_on_past": False,
    "retries": 3,
    "retry_delay": timedelta(seconds=10),
}

my_dag = DAG(
    dag_id="api_to_rds",
    default_args=default_args,
    description=(
        "An ETL pipeline for extracting from api data and loading into "
        "rds postgress database"
    ),
    schedule_interval="@daily",
    start_date=datetime(2025, 7, 30)
)

extract_task = PythonOperator(
    dag=my_dag,
    python_callable=get_results,
    task_id="extract_data"
)


load_task = PythonOperator(
    dag=my_dag,
    python_callable=load_to_rds,
    task_id="load_data"
)

extract_task >> load_task
