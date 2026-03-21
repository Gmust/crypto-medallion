# GCP setup checklist

Use this once per team (or per environment). Adjust names to match [naming_conventions.md](naming_conventions.md).

## 1. Project

- [ ] Create a GCP project (or use one provided by the course).
- [ ] Note the **Project ID** (used in code and SQL).
- [ ] Enable billing if required by the course.

## 2. APIs

- [ ] Enable **BigQuery API**.
- [ ] Enable **Cloud Storage API**.

(Console: APIs & Services → Enable APIs, or use `gcloud services enable` for the above.)

## 3. Cloud Storage

- [ ] Create a **regional or multi-region** bucket for raw files (name must be globally unique).
- [ ] Optional: create a folder prefix such as `crypto/raw/` for uploads.

## 4. BigQuery datasets

Create three datasets in the same project (locations should match your bucket/team policy):

- [ ] `crypto_bronze` — raw loads from GCS.
- [ ] `crypto_silver` — cleaned tables.
- [ ] `crypto_gold` — aggregated / reporting tables.

## 5. Access (IAM)

- [ ] Add teammates with roles appropriate for class work, e.g. **BigQuery Data Editor**, **Storage Object Admin** (or narrower if policy requires).
- [ ] Avoid sharing owner keys; prefer individual accounts or group-based access.
- [ ] Confirm everyone can run queries in BigQuery and list/upload to the bucket.

## 6. Local development

- [ ] Install [Google Cloud SDK](https://cloud.google.com/sdk/docs/install).
- [ ] Run `gcloud auth login` and `gcloud auth application-default login` for local Python scripts.
- [ ] Set default project: `gcloud config set project YOUR_PROJECT_ID`.

## 7. First pipeline smoke test

- [ ] Upload a small test CSV to GCS (or use `bronze/ingest_local_to_gcs.py`).
- [ ] Load into a Bronze table (or use `bronze/load_gcs_to_bigquery.py`).
- [ ] Run `SELECT COUNT(*) FROM ...` in BigQuery to confirm.
