# Bronze layer

## Purpose

Bronze holds **raw** cryptocurrency data exactly as delivered from the source (Kaggle CSV). This layer is for **landed** data: file storage plus a load into BigQuery for querying and downstream SQL.

## Rules

- **Do not** modify or “fix” raw content in Bronze beyond what is required to load (e.g. CSV format). Business cleaning belongs in **Silver**.
- Keep **one clear path**: local file → **Google Cloud Storage (GCS)** → **BigQuery** Bronze table.

## Flow

1. Download the Kaggle dataset locally (team policy: where to store it is up to you; paths go in config).
2. Run `ingest_local_to_gcs.py` to upload the file to your GCS bucket.
3. Run `load_gcs_to_bigquery.py` to load that object into a BigQuery table in the Bronze dataset.

Adjust `config.json` (from `config.example.json`) for `project_id`, bucket, dataset, table name, and paths.

## Requirements

```bash
python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

Authenticate to GCP with Application Default Credentials (e.g. `gcloud auth application-default login`) for local runs.
