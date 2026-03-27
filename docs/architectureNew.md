# Medallion Architecture Overview

## 1. Purpose

This document how exactly project use Medallion architecture and how data moves across **Bronze → Silver → Gold** using **Google Cloud Storage (GCS)** and **BigQuery**.

The goal of the project is to keep raw data separate from cleaned data and business-ready outputs, so the pipeline is easier to understand, validate, and extend.

---

## 2. High-level architecture

The system follows Medallion pattern:

- **Bronze** stores raw ingested data with minimal transformation.
- **Silver** stores cleaned and standardized data ready for analytical use.
- **Gold** stores curated business-level outputs such as summaries, aggregates, and reporting tables.

### Main platforms used

- **Google Cloud Storage (GCS)**: landing zone for source files such as CSV uploads.
- **BigQuery**: analytical warehouse that stores Bronze, Silver, and Gold datasets.

---

## 3. Layer descriptions

### Bronze layer

**Purpose**

The Bronze layer preserves source data in its raw form. It acts as the first durable ingestion point and is used for traceability, replay, and troubleshooting.

**What happens here**

- A local CSV file is uploaded to GCS.
- The CSV object from GCS is loaded into a Bronze table in BigQuery.
- Schema can initially be autodetected, with the option to replace it later with an explicit schema.
- Data is not heavily transformed at this stage.

**Why it exists**

- Keeps the original data close to the source.
- Makes it possible to reload downstream layers if logic changes.
- Helps with debugging ingestion issues.

---

### Silver layer

**Purpose**

The Silver layer contains cleaned, typed, validated, and standardized data. This is the operational analytics layer where raw source inconsistencies are resolved.

**What happens here**

- Column names are standardized.
- Data types are corrected and enforced.
- Null handling and basic quality checks are applied.
- Duplicate rows can be removed if needed.
- Date, numeric, and symbol fields are normalized.

**Why it exists**

- Provides a trusted row-level dataset for analysis.
- Separates data quality logic from final business reporting.
- Reduces repeated cleaning logic in downstream queries.

---

### Gold layer

**Purpose**

The Gold layer contains business-ready outputs optimized for reporting, dashboarding , and consumption by end users or analytical stakeholders.

**What happens here**

- Silver data is aggregated into final metrics.
- Tables are shaped around clear analytical use cases.
- Outputs may be persisted as tables or generated as reusable views/queries.

**Why it exists**

- Gives consumers a stable and simple interface.
- Hides row-level cleaning complexity.
- Improves performance for repeated reporting use cases.

---

## 4. Data flow between layers

### End-to-end flow

1. A source CSV exists locally.
2. The file is uploaded to **GCS** using environment variables from `.env`.
3. The file in GCS is loaded into a **Bronze** table in BigQuery.
4. Bronze data is transformed into a cleaned **Silver** table.
5. Silver data is aggregated into **Gold** tables for analytics and reporting.

### Logical flow

- **Local file** → landing input
- **GCS** → raw object storage / ingestion layer
- **BigQuery Bronze** → raw table load
- **BigQuery Silver** → cleaned, standardized table
- **BigQuery Gold** → curated analytics outputs

### Design principle

Each layer should depend only on the layer immediately before it:

- Gold reads from Silver
- Silver reads from Bronze
- Bronze reads from GCS

This keeps the architecture modular and easier to maintain.

---

## 5. Simple diagram

```text
+------------------+
|   Local CSV      |
|   source file    |
+---------+--------+
          |
          | upload
          v
+------------------+
| Google Cloud     |
| Storage (GCS)    |
| raw object       |
+---------+--------+
          |
          | load job
          v
+-----------------------------+
| BigQuery Bronze             |
| dataset: crypto_bronze      |
| table:   crypto_raw         |
+-------------+---------------+
              |
              | clean / standardize
              v
+-----------------------------+
| BigQuery Silver             |
| dataset: crypto_silver      |
| table:   crypto_clean       |
+-------------+---------------+
              |
              | aggregate / model
              v
+----------------------------------------------+
| BigQuery Gold                                |
| dataset: crypto_gold                         |
| tables: daily_summary / top_movers /         |
|         volatility                           |
+----------------------------------------------+
```

---

## 6. Naming conventions

The project should use **lowercase with underscores** for readability and consistency.

### BigQuery datasets

- `crypto_bronze` — raw tables loaded from GCS
- `crypto_silver` — cleaned and standardized tables
- `crypto_gold` — reporting and aggregated tables

### BigQuery tables

Recommended examples:

- Bronze: `crypto_raw`
- Silver: `crypto_clean`
- Gold: `daily_summary`
- Gold: `top_movers`
- Gold: `volatility`

### GCS bucket

Recommended pattern:

- `crypto-medallion-<team-or-project-suffix>`

Example:

- `crypto-medallion-team1`

### GCS object paths

Keep object paths explicit and grouped by purpose.

Recommended pattern:

- `crypto/raw/<filename>.csv`

### Branch naming

Recommended Git branch patterns:

- `main`
- `feature/<short-description>`
- `fix/<short-description>`

---

## 7. Folder structure

A simple project structure should separate ingestion, transformation, SQL, and documentation.

```text
repo-root/
├── .env
├── .env.example
├── bronze/
│   ├── ingest_local_to_gcs.py
│   └── load_gcs_to_bigquery.py
├── silver/
│   └── ... transformation logic or SQL definitions
├── gold/
│   ├── daily_summary.sql
│   ├── top_movers.sql
│   └── volatility.sql
├── docs/
│   ├── architecture.md
│   ├── naming_conventions.md
│   └── gcp_setup_checklist.md
└── README.md
```

### Folder purpose

- **repo-root/.env**: stores environment-specific values such as project ID, bucket name, dataset names, table names, and file paths.
- **bronze/**: ingestion-related scripts for moving data into GCS and loading it into BigQuery.
- **silver/**: logic for cleaning and standardizing Bronze data.
- **gold/**: SQL for final aggregates and analytical outputs.
- **docs/**: architecture and operational documentation.

### Recommended rule

Keep one responsibility per folder:

- ingestion in `bronze/`
- cleaning in `silver/`
- aggregation in `gold/`
- documentation in `docs/`

---

## 8. Orchestration

### How the pipeline is triggered

The Pipeline can be started in **two simple ways**: **manually** or **on a schedule**.

The idea is always the same — data should move through the Medallion layers in the correct order:

**GCS → Bronze → Silver → Gold**

---

### 1. Manual trigger

This means a team member starts each step one after another:

1. Upload the local file to **Google Cloud Storage (GCS)**
2. Load that file into the **Bronze** table in **BigQuery**
3. Run the **Silver** transformation
4. Run the **Gold** transformation queries

This is useful during development because it makes the process easier to test, debug, and understand step by step.

---

### 2. Scheduled trigger

In this case, the process runs automatically at a defined interval, for example:

- every day
- every hour
- once per week

A scheduler or orchestration service starts the pipeline without requiring manual input.

This is the setup for a production-like environment because it reduces repetitive manual work and makes the data flow more consistent.

---

### Typical scheduled pipeline flow

A scheduled run would look like this:

- the scheduler starts the pipeline
- the system checks whether the expected input file is available
- the **Bronze** load starts
- the **Silver** transformation runs
- the **Gold** tables are refreshed
- the system records logs and execution status

This ensures the pipeline behaves in a predictable and repeatable way.

---

### Recommended orchestration logic

Whether the pipeline is started manually or automatically, it should always follow the same sequence.

Each step depends on the previous one being completed successfully:

1. **File uploaded to GCS**
2. **Bronze load completed**
3. **Silver transformation completed**
4. **Gold layer refreshed**

If one step fails, the next step should **not** continue automatically.

This keeps the pipeline reliable and helps prevent incomplete or inconsistent data from reaching later layers.

---

### What orchestration make visible

A good orchestration process should make it easy to understand **what happened during a run**.

At minimum, it should clearly answer:

- What started the pipeline?
- Which file was processed?
- Did the **Bronze** step finish successfully?
- Did the **Silver** step finish successfully?
- Did the **Gold** step finish successfully?
- If something failed, **where** did it fail?

This is important both for debugging and for basic operational control.

---

### Recommended approach for this project

For this project, the most practical setup is:

- **Development mode** → run the pipeline manually
- **Demo / production-like mode** → run the pipeline on a schedule

This gives the team a workflow that is easy to manage during implementation, while also showing how the solution could work in a more automated real-world setup.

## 9. Environment variables used by the current flow

The provided ingestion scripts already imply a parameterized setup through `.env`.

File named `.env.example` contains all needed variables

---

## 10. Architectural summary

This solution uses a clear Medallion architecture on GCP:

- **GCS** is the landing zone for raw source files.
- **Bronze** stores raw ingested data in BigQuery.
- **Silver** stores cleaned and standardized row-level data.
- **Gold** stores final analytical outputs such as summaries, movers, and volatility metrics.

The design is simple, modular, and easy to document:

- each layer has a distinct purpose,
- each downstream layer depends only on the previous layer,
- naming is standardized,
- folder responsibilities are clear,
- orchestration can begin manually and later move to a schedule.

---
