# Silver Layer

## Purpose

Silver contains **cleaned, typed, and standardized** tables built from Bronze. Typical steps:

- Consistent column names (e.g. snake_case)
- Safe casting and typing (`SAFE_CAST`, explicit `DATE`/`TIMESTAMP` where needed)
- Removal of obvious bad rows (null keys, duplicates) **without** applying final business KPIs

## What Silver is not

- **Not** the place for heavy reporting aggregates (those belong in **Gold**).
- **Not** a copy-paste of Bronze with a new name; it should reflect real cleaning decisions agreed by the team.

## Tables

### `crypto_silver.clean_crypto`

**Source:** `crypto_bronze.raw_crypto`

**Row Count:** ~4,150 records

**Purpose:** Single source of truth for clean crypto data. Used by all Gold layer analytics.

## Transformations Applied

### Column Name Standardization
- Removed leading/trailing spaces from column names
- Converted to lowercase with underscores
- Examples:
  - `" Price "` → `price_usd`
  - `" 24h Volume "` → `volume_24h_usd`
  - `" Market Cap "` → `market_cap_usd`

### Data Type Conversions
- **Percentages:** Removed `%` symbols, converted to `FLOAT64`
  - `"2.70%"` → `2.70` (pct_change_24h)
  - `"-6.60%"` → `-6.60` (pct_change_7d)

- **Currency:** Removed `$`, commas, and spaces, converted to `FLOAT64`
  - `"$34,922,035.00"` → `34922035.00` (market_cap_usd)
  - `"$6,015.00"` → `6015.00` (volume_24h_usd)

- **Supply:** Handled "Million" and "Billion" suffixes with numeric conversion
  - `"3.53 Million"` → `3530000.0` (total_supply)
  - Already numeric columns (e.g., `Circulating Supply`) cast to `FLOAT64`

- **Identifiers:** Trimmed and normalized text columns
  - `Coin Name` → `coin_name` (lowercase)
  - `Symbol` → `symbol` (uppercase)

### Data Quality
- **is_complete_record:** Boolean flag indicating if all required fields (coin_name, price_usd, market_cap_usd) are non-null
- Rows with missing critical fields are flagged but **not** removed (filtering happens in Gold)

## Columns

| Column | Type | Description |
|--------|------|-------------|
| record_id | INT64 | Surrogate key for traceability |
| rank | INT64 | Cryptocurrency ranking |
| coin_name | STRING | Coin name (lowercase) |
| symbol | STRING | Ticker symbol (uppercase) |
| price_usd | FLOAT64 | Current price in USD |
| pct_change_1h | FLOAT64 | Price change % (1 hour) |
| pct_change_24h | FLOAT64 | Price change % (24 hours) |
| pct_change_7d | FLOAT64 | Price change % (7 days) |
| pct_change_30d | FLOAT64 | Price change % (30 days) |
| volume_24h_usd | FLOAT64 | Trading volume (24h) in USD |
| circulating_supply | FLOAT64 | Coins in circulation |
| total_supply | FLOAT64 | Total coins ever created |
| market_cap_usd | FLOAT64 | Market capitalization in USD |
| loaded_at | TIMESTAMP | When data was loaded (CURRENT_TIMESTAMP) |
| is_complete_record | BOOLEAN | All required fields populated |
| silver_created_at | TIMESTAMP | When Silver table was created |
| silver_created_by | STRING | User who created Silver table |

## Usage

1. Confirm Bronze table (`crypto_bronze.raw_crypto`) and column names in BigQuery.
2. Review `01_create_clean_crypto.sql`: verify column name mappings and transformations match your Bronze schema.
3. Run the SQL file to create or replace the Silver table in dataset `crypto_silver`.
4. Validate row count and data types: `SELECT COUNT(*) FROM crypto_silver.clean_crypto; DESCRIBE crypto_silver.clean_crypto;`

## Sample Query

```sql
SELECT
  rank,
  coin_name,
  symbol,
  price_usd,
  market_cap_usd,
  pct_change_24h
FROM `outstanding-map-490915-u5.crypto_silver.clean_crypto`
WHERE is_complete_record = TRUE
ORDER BY market_cap_usd DESC
LIMIT 10;