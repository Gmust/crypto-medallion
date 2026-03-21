# Naming conventions

Keep names **lowercase with underscores** unless a GCP product forces otherwise.

## BigQuery datasets

| Dataset | Purpose |
|---------|---------|
| `crypto_bronze` | Raw tables loaded from GCS |
| `crypto_silver` | Cleaned, standardized tables |
| `crypto_gold` | Aggregates and reporting tables |

## BigQuery tables (examples)

| Table | Layer | Description |
|-------|--------|-------------|
| `crypto_raw` | Bronze | Raw CSV load |
| `crypto_clean` | Silver | Cleaned row-level data |
| `daily_summary` | Gold | Daily aggregates |
| `top_movers` | Gold | Optional saved query results (if materialized) |

Prefix or suffix extra tables consistently, e.g. `gold_daily_summary` vs `daily_summary` — pick one style for the team.

## Cloud Storage bucket

- Pattern: `crypto-medallion-<team-or-project-suffix>` (must be globally unique).
- Object paths: `crypto/raw/<filename>.csv` or similar — keep a clear prefix for “landing zone” files.

## Git branches

| Pattern | Use |
|---------|-----|
| `main` | Protected; stable code only |
| `feature/<short-description>` | Work in progress (e.g. `feature/bronze-ingest`) |
| `fix/<short-description>` | Bugfixes |

Do not commit directly to `main` for class workflow; use feature branches and pull requests as in [docs/workflow.md](../docs/workflow.md).
