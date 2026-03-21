# Gold layer

## Purpose

Gold holds **business-ready, aggregated** tables for analysis, dashboards, and assignment deliverables. They are built from **Silver** (and only reference Bronze if there is a rare exception the team documents).

Examples in this repo:

- **Top movers** — largest price changes over a window you define
- **Daily summary** — per-day metrics per asset
- **Volatility** — rolling or daily volatility-style metrics

Each SQL file is a **template**: adjust time windows, symbols, and column names after Silver is finalized.
