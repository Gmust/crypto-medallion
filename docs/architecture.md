# Architecture

## Medallion (Bronze → Silver → Gold)

The **Medallion** pattern layers data by **how much it has been processed**:

1. **Bronze** — Data lands **as received** (plus technical load settings). Minimal transformation; good for auditing and reprocessing.
2. **Silver** — **Cleaned and conformed** data: types, names, deduplication rules. Still row-level detail.
3. **Gold** — **Curated aggregates and metrics** for analysis, dashboards, and assignments.

This keeps responsibilities clear: ingest is separate from cleaning, and cleaning is separate from business-facing metrics.

## Data flow (this project)

```
Kaggle CSV (local)
        │
        ▼
Google Cloud Storage (raw object)
        │
        ▼
BigQuery: crypto_bronze (e.g. crypto_raw)
        │
        ▼
BigQuery: crypto_silver (e.g. crypto_clean)   ← SQL transforms
        │
        ▼
BigQuery: crypto_gold (e.g. daily_summary)    ← SQL transforms
```

Python scripts in `bronze/` automate **local file → GCS → BigQuery Bronze**. Silver and Gold are **SQL** run in BigQuery (or exported and run by your CI later if you add it).

## Design choices (educational scope)

- One cloud project and one bucket are enough to start.
- No requirement for streaming, data lakes beyond GCS, or orchestration tools unless the course adds them later.
