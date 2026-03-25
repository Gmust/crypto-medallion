# Bronze layer

## Purpose

Bronze holds **raw** cryptocurrency data exactly as delivered from the source (Kaggle CSV). This layer is for **landed** data: file storage plus a load into BigQuery for querying and downstream SQL.

## Rules

- **Do not** modify or “fix” raw content in Bronze beyond what is required to load (e.g. CSV format). Business cleaning belongs in **Silver**.
- Keep **one clear path**: local file → **Google Cloud Storage (GCS)** → **BigQuery** Bronze table.

## Flow

1. Download the Kaggle dataset locally (e.g. under `data/`; set `LOCAL_FILE_PATH` in `.env`).
2. Copy `.env.example` to `.env` at the **repository root** and set `GCP_PROJECT_ID`, `GCS_*`, `BIGQUERY_*`, and `LOCAL_FILE_PATH`.
3. Run `ingest_local_to_gcs.py` to upload the file to your GCS bucket.
4. Run `load_gcs_to_bigquery.py` to load that object into a BigQuery table in the Bronze dataset.

Scripts load environment variables from `.env` via `python-dotenv` (never commit `.env`).

## Requirements

```bash
python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r bronze\requirements.txt
```

## GCP authentication (local runs)

The scripts use the **Google Cloud client libraries**, which read [**Application Default Credentials**](https://cloud.google.com/docs/authentication/application-default-credentials) (ADC). Values in `.env` (project id, bucket, etc.) are **not** the same as login credentials.

1. Install the [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) (`gcloud` on your PATH).
2. Sign in for user credentials (browser):

   ```bash
   gcloud auth login
   gcloud config set project YOUR_GCP_PROJECT_ID
   ```

3. Create ADC for libraries such as `google-cloud-storage` and `google-cloud-bigquery`:

   ```bash
   gcloud auth application-default login
   ```

4. Run the Bronze scripts again from the repo root (with your venv activated if you use one).

If you use a **service account key** instead (e.g. on CI), set `GOOGLE_APPLICATION_CREDENTIALS` to the JSON key path; do not commit that file.
