# crypto-medallion

Educational Big Data project for class: a **Medallion** data pipeline on **Google Cloud** using Python for Bronze ingestion and SQL for Silver and Gold transformations. Source data is a cryptocurrency dataset from [Kaggle](https://www.kaggle.com/).

## Medallion layers

| Layer | Role |
|--------|------|
| **Bronze** | Raw data as ingested (CSV → Cloud Storage → BigQuery). No business rules; preserve source fidelity. |
| **Silver** | Cleaned, typed, standardized tables. No final business aggregates. |
| **Gold** | Aggregated, analysis-ready tables for reporting and assignments. |

## Repository layout

```
crypto-medallion/
├── .env.example     # Template for local .env (copy to .env)
├── bronze/          # Ingestion scripts
├── silver/          # SQL for cleaned Silver tables
├── gold/            # SQL for Gold analytics
├── infrastructure/  # GCP setup checklists and naming rules
└── docs/            # Architecture, team roles, Git workflow
```

## Team roles (summary)

| Area | Focus |
|------|--------|
| Bronze / pipeline | Raw ingest, GCS, BigQuery load |
| Silver / Gold | SQL transforms, data quality |
| Infrastructure | GCP project, buckets, IAM |
| Docs / coordination | READMEs, workflow, alignment |
| Validation / QA | Checks before merges and runs |

See [docs/team-responsibilities.md](docs/team-responsibilities.md) for the full table.

## Getting started

1. **GCP**: Follow [infrastructure/gcp_setup_checklist.md](infrastructure/gcp_setup_checklist.md) and [infrastructure/naming_conventions.md](infrastructure/naming_conventions.md).
2. **Bronze**: Copy `.env.example` to `.env` in the repo root, set GCP and paths, install deps (`pip install -r bronze/requirements.txt`), run ingest then load scripts (see [bronze/README.md](bronze/README.md)).
3. **Silver / Gold**: Run SQL in BigQuery (or your SQL runner) against the datasets you created, adjusting table and column names to match your Kaggle file.

Use a Python virtual environment and **never commit** `.env` (see `.gitignore`).
