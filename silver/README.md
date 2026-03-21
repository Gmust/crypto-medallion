# Silver layer

## Purpose

Silver contains **cleaned, typed, and standardized** tables built from Bronze. Typical steps:

- Consistent column names (e.g. snake_case)
- Safe casting and typing (`SAFE_CAST`, explicit `DATE`/`TIMESTAMP` where needed)
- Removal of obvious bad rows (null keys, duplicates) **without** applying final business KPIs

## What Silver is not

- **Not** the place for heavy reporting aggregates (those belong in **Gold**).
- **Not** a copy-paste of Bronze with a new name; it should reflect real cleaning decisions agreed by the team.

## Usage

1. Confirm Bronze table and column names in BigQuery after your Kaggle load.
2. Edit `clean_crypto_data.sql`: replace placeholders and TODOs to match your actual schema.
3. Create or replace the Silver table in dataset `crypto_silver` (see [infrastructure/naming_conventions.md](../infrastructure/naming_conventions.md)).
