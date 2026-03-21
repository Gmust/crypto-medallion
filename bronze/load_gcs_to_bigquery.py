"""
Load a CSV object from GCS into a BigQuery Bronze table.
Schema: uses autodetect by default; see SCHEMA definition below to pin columns after you inspect the CSV.
"""

from __future__ import annotations

import json
import logging
import sys
from pathlib import Path

from typing import Any, Optional

from google.cloud import bigquery
from google.cloud.exceptions import GoogleCloudError

LOGGER = logging.getLogger(__name__)

DEFAULT_CONFIG = Path(__file__).resolve().parent / "config.json"

# TODO: After inspecting your Kaggle CSV headers and types, optionally replace autodetect
# with an explicit schema list, e.g.:
# SCHEMA = [
#     bigquery.SchemaField("symbol", "STRING"),
#     bigquery.SchemaField("date", "DATE"),
#     ...
# ]
SCHEMA: Optional[list[Any]] = None  # None = autodetect


def load_config(path: Path) -> dict:
    if not path.is_file():
        raise FileNotFoundError(
            f"Config not found: {path}. Copy config.example.json to config.json and edit."
        )
    with path.open(encoding="utf-8") as f:
        return json.load(f)


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
    config_path = Path(
        sys.argv[1] if len(sys.argv) > 1 else DEFAULT_CONFIG
    ).expanduser()

    try:
        cfg = load_config(config_path)
        project_id = cfg["project_id"]
        bucket_name = cfg["bucket_name"]
        gcs_blob_name = cfg["gcs_blob_name"]
        dataset_bronze = cfg["dataset_bronze"]
        table_raw = cfg["table_raw"]
    except (KeyError, json.JSONDecodeError) as e:
        LOGGER.error("Invalid config: %s", e)
        return 1

    try:
        run_load(
            project_id,
            bucket_name,
            gcs_blob_name,
            dataset_bronze,
            table_raw,
        )
    except (GoogleCloudError, OSError) as e:
        LOGGER.error("%s", e)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
