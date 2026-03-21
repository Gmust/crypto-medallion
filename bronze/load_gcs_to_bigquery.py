"""
Load a CSV object from GCS into a BigQuery Bronze table.
Reads GCP settings from .env (repository root).
Schema: uses autodetect by default; see SCHEMA definition below to pin columns after you inspect the CSV.
"""

from __future__ import annotations

import logging
import os
from pathlib import Path
from typing import Any, Optional

from dotenv import load_dotenv
from google.auth.exceptions import DefaultCredentialsError
from google.cloud import bigquery
from google.cloud.exceptions import GoogleCloudError

LOGGER = logging.getLogger(__name__)

REPO_ROOT = Path(__file__).resolve().parent.parent

# TODO: After inspecting your Kaggle CSV headers and types, optionally replace autodetect
# with an explicit schema list, e.g.:
# SCHEMA = [
#     bigquery.SchemaField("symbol", "STRING"),
#     bigquery.SchemaField("date", "DATE"),
#     ...
# ]
SCHEMA: Optional[list[Any]] = None  # None = autodetect


def load_env() -> None:
    load_dotenv(REPO_ROOT / ".env")


def require_env(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        raise ValueError(
            f"Missing or empty environment variable: {name}. "
            "Copy .env.example to .env in the repo root and set values."
        )
    return value


def run_load(
    project_id: str,
    bucket_name: str,
    gcs_blob_name: str,
    dataset_id: str,
    table_id: str,
) -> None:
    client = bigquery.Client(project=project_id)
    table_ref = f"{project_id}.{dataset_id}.{table_id}"
    gcs_uri = f"gs://{bucket_name}/{gcs_blob_name}"

    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=1,
        autodetect=SCHEMA is None,
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
        # TODO: If the CSV uses a non-comma delimiter, set field_delimiter=...
    )
    if SCHEMA is not None:
        job_config.schema = SCHEMA

    LOGGER.info("Loading %s into %s", gcs_uri, table_ref)
    load_job = client.load_table_from_uri(
        gcs_uri, table_ref, job_config=job_config
    )
    load_job.result()
    table = client.get_table(table_ref)
    LOGGER.info("Loaded %s rows into %s", table.num_rows, table_ref)


def main() -> int:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",
    )
    load_env()

    try:
        project_id = require_env("GCP_PROJECT_ID")
        bucket_name = require_env("GCS_BUCKET_NAME")
        gcs_blob_name = require_env("GCS_BLOB_NAME")
        dataset_bronze = require_env("BIGQUERY_DATASET_BRONZE")
        table_raw = require_env("BIGQUERY_TABLE_RAW")
    except ValueError as e:
        LOGGER.error("%s", e)
        return 1

    try:
        run_load(
            project_id,
            bucket_name,
            gcs_blob_name,
            dataset_bronze,
            table_raw,
        )
    except DefaultCredentialsError:
        LOGGER.error(
            "No Google credentials found. Run: gcloud auth application-default login\n"
            "Or set GOOGLE_APPLICATION_CREDENTIALS in .env to a service account JSON path."
        )
        return 1
    except (GoogleCloudError, OSError) as e:
        LOGGER.error("%s", e)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
