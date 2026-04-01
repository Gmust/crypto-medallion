import os
import functions_framework
from google.cloud import bigquery

bq_client = bigquery.Client()

BQ_TABLE_ID = os.environ.get("BQ_TABLE_ID", "your-project.bronze.cryptocurrency_data")

@functions_framework.cloud_event
def load_gcs_to_bq(cloud_event):
    
    data = cloud_event.data
    bucket_name = data["bucket"]
    file_name = data["name"]

    if not file_name.endswith('.csv'):
        print(f"Skipping non-CSV file: {file_name}")
        return

    uri = f"gs://{bucket_name}/{file_name}"
    print(f"Detected new CSV: {uri}")
    print(f"Starting BigQuery load job into {BQ_TABLE_ID}...")

    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=1, 
        autodetect=True,     
        write_disposition=bigquery.WriteDisposition.WRITE_APPEND 
    )

    load_job = bq_client.load_table_from_uri(
        uri,
        BQ_TABLE_ID,
        job_config=job_config
    )

    load_job.result()

    print(f"Success! Loaded {load_job.output_rows} rows into {BQ_TABLE_ID}.")