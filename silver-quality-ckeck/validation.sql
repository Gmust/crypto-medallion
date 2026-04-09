-- =========================================
-- Data Quality Validation
-- Project: Crypto Medallion Architecture
-- Role: Data Quality Engineer
-- Dataset: crypto_silver.clean_crypto
-- =========================================


-- =====================================================
-- BASIC CHECKS
-- =====================================================

-- 1. Bronze vs Silver Row Count Check
-- Purpose: Verify that no rows were lost during transformation

SELECT COUNT(*) AS bronze_row_count
FROM `outstanding-map-490915-u5.crypto_bronze.raw_crypto`;

SELECT COUNT(*) AS silver_row_count
FROM `outstanding-map-490915-u5.crypto_silver.clean_crypto`;

-- Result:
-- bronze_row_count = 4150
-- silver_row_count = 4150
-- Conclusion:
-- No row loss detected between Bronze and Silver.


-- 2. Null Value Check
-- Purpose: Identify missing values in key Silver columns

SELECT
  COUNTIF(record_id IS NULL) AS null_record_id,
  COUNTIF(rank IS NULL) AS null_rank,
  COUNTIF(coin_name IS NULL) AS null_coin_name,
  COUNTIF(symbol IS NULL) AS null_symbol,
  COUNTIF(price_usd IS NULL) AS null_price_usd,
  COUNTIF(pct_change_1h IS NULL) AS null_pct_change_1h,
  COUNTIF(pct_change_24h IS NULL) AS null_pct_change_24h,
  COUNTIF(pct_change_7d IS NULL) AS null_pct_change_7d,
  COUNTIF(pct_change_30d IS NULL) AS null_pct_change_30d,
  COUNTIF(volume_24h_usd IS NULL) AS null_volume_24h_usd,
  COUNTIF(circulating_supply IS NULL) AS null_circulating_supply,
  COUNTIF(total_supply IS NULL) AS null_total_supply,
  COUNTIF(market_cap_usd IS NULL) AS null_market_cap_usd,
  COUNTIF(loaded_at IS NULL) AS null_loaded_at,
  COUNTIF(is_complete_record IS NULL) AS null_is_complete_record,
  COUNTIF(silver_created_at IS NULL) AS null_silver_created_at,
  COUNTIF(silver_created_by IS NULL) AS null_silver_created_by
FROM `outstanding-map-490915-u5.crypto_silver.clean_crypto`;

-- Result Summary:
-- null_record_id = 0
-- null_rank = 0
-- null_coin_name = 0
-- null_symbol = 0
-- null_price_usd = 1726
-- null_pct_change_1h = 547
-- null_pct_change_24h = 452
-- null_pct_change_7d = 454
-- null_pct_change_30d = 509
-- null_volume_24h_usd = 484
-- null_circulating_supply = 0
-- null_total_supply = 495
-- null_market_cap_usd = 410
-- null_loaded_at = 0
-- null_is_complete_record = 0
-- null_silver_created_at = 0
-- null_silver_created_by = 0
-- Conclusion:
-- Key identifier fields are complete, but analytical market fields contain missing values.


-- 3. Duplicate Record Check
-- Purpose: Detect duplicate rows in Silver

SELECT
  record_id,
  coin_name,
  symbol,
  COUNT(*) AS duplicate_count
FROM `outstanding-map-490915-u5.crypto_silver.clean_crypto`
GROUP BY record_id, coin_name, symbol
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Result:
-- No duplicate records found.
-- Conclusion:
-- Transformation did not introduce duplicate rows.


-- =====================================================
-- COMPLETENESS CHECKS
-- =====================================================

-- 4. Completeness Check
-- Purpose: Count complete vs incomplete records

SELECT
  is_complete_record,
  COUNT(*) AS record_count
FROM `outstanding-map-490915-u5.crypto_silver.clean_crypto`
GROUP BY is_complete_record;

-- Result:
-- TRUE  = 2262
-- FALSE = 1888
-- Conclusion:
-- A significant portion of records is incomplete.


-- 5. Missing Value Percentage Check
-- Purpose: Measure null percentages in important analytical columns

SELECT
  COUNT(*) AS total_rows,
  ROUND(100 * COUNTIF(price_usd IS NULL) / COUNT(*), 2) AS pct_null_price_usd,
  ROUND(100 * COUNTIF(pct_change_1h IS NULL) / COUNT(*), 2) AS pct_null_pct_change_1h,
  ROUND(100 * COUNTIF(pct_change_24h IS NULL) / COUNT(*), 2) AS pct_null_pct_change_24h,
  ROUND(100 * COUNTIF(pct_change_7d IS NULL) / COUNT(*), 2) AS pct_null_pct_change_7d,
  ROUND(100 * COUNTIF(pct_change_30d IS NULL) / COUNT(*), 2) AS pct_null_pct_change_30d,
  ROUND(100 * COUNTIF(volume_24h_usd IS NULL) / COUNT(*), 2) AS pct_null_volume_24h_usd,
  ROUND(100 * COUNTIF(total_supply IS NULL) / COUNT(*), 2) AS pct_null_total_supply,
  ROUND(100 * COUNTIF(market_cap_usd IS NULL) / COUNT(*), 2) AS pct_null_market_cap_usd
FROM `outstanding-map-490915-u5.crypto_silver.clean_crypto`;

-- Result:
-- total_rows = 4150
-- pct_null_price_usd = 41.59
-- pct_null_pct_change_1h = 13.18
-- pct_null_pct_change_24h = 10.89
-- pct_null_pct_change_7d = 10.94
-- pct_null_pct_change_30d = 12.27
-- pct_null_volume_24h_usd = 11.66
-- pct_null_total_supply = 11.93
-- pct_null_market_cap_usd = 9.88
-- Conclusion:
-- Missing values are concentrated mainly in analytical market metrics.


-- =====================================================
-- CONSISTENCY CHECKS
-- =====================================================

-- 6. Record ID Uniqueness Check
-- Purpose: Verify uniqueness of record_id

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT record_id) AS unique_record_ids,
  COUNT(*) - COUNT(DISTINCT record_id) AS duplicate_record_ids
FROM `outstanding-map-490915-u5.crypto_silver.clean_crypto`;

-- Result:
-- total_rows = 4150
-- unique_record_ids = 4150
-- duplicate_record_ids = 0
-- Conclusion:
-- record_id is unique across the Silver dataset.


-- 7. Coin Name Consistency Check
-- Purpose: Detect coin names linked to multiple symbols

SELECT
  coin_name,
  COUNT(DISTINCT symbol) AS distinct_symbols
FROM `outstanding-map-490915-u5.crypto_silver.clean_crypto`
GROUP BY coin_name
HAVING COUNT(DISTINCT symbol) > 1
ORDER BY distinct_symbols DESC;

-- Result:
-- Example findings:
-- stacks     = 2 symbols
-- worldcoin  = 2 symbols
-- Only a small number of coin names showed symbol inconsistency.
-- Conclusion:
-- Some coin names are associated with multiple symbols, indicating naming inconsistency.


-- 8. Symbol Consistency Check
-- Purpose: Detect symbols linked to multiple coin names

SELECT
  symbol,
  COUNT(DISTINCT coin_name) AS distinct_names
FROM `outstanding-map-490915-u5.crypto_silver.clean_crypto`
GROUP BY symbol
HAVING COUNT(DISTINCT coin_name) > 1
ORDER BY distinct_names DESC;

-- Result:
-- Multiple symbols map to more than one coin name.
-- Example findings include:
-- MINT = 4 names
-- CAT = 4 names
-- EGG = 4 names
-- MEME = 4 names
-- BANK = 3 names
-- SHIB = 3 names
-- Conclusion:
-- symbol should not be treated as a globally unique business identifier.


-- =====================================================
-- BUSINESS LOGIC CHECKS
-- =====================================================

-- 9. Negative Value Check
-- Purpose: Detect invalid negative values in key numerical fields

SELECT *
FROM `outstanding-map-490915-u5.crypto_silver.clean_crypto`
WHERE
  price_usd < 0
  OR market_cap_usd < 0
  OR volume_24h_usd < 0
  OR circulating_supply < 0
  OR total_supply < 0;

-- Result:
-- No records returned.
-- Conclusion:
-- No negative values detected. All key numerical fields are logically valid.


-- 10. Supply Consistency Check
-- Purpose: Detect records where circulating_supply exceeds total_supply

SELECT *
FROM `outstanding-map-490915-u5.crypto_silver.clean_crypto`
WHERE
  total_supply IS NOT NULL
  AND circulating_supply > total_supply;

-- Result:
-- Multiple records returned, indicating recurring supply inconsistencies.
-- Example violations include cases where circulating_supply is greater than total_supply.
-- Conclusion:
-- Some records violate expected supply consistency rules and should be treated as business logic anomalies.


-- 11. Market Cap Consistency Check
-- Purpose: Validate that market_cap_usd aligns with price_usd * circulating_supply

SELECT
  record_id,
  coin_name,
  symbol,
  price_usd,
  circulating_supply,
  market_cap_usd,
  (price_usd * circulating_supply) AS calculated_market_cap,
  ABS(market_cap_usd - (price_usd * circulating_supply)) AS cap_difference
FROM `outstanding-map-490915-u5.crypto_silver.clean_crypto`
WHERE
  price_usd IS NOT NULL
  AND circulating_supply IS NOT NULL
  AND market_cap_usd IS NOT NULL
  AND ABS(market_cap_usd - (price_usd * circulating_supply)) > 1000000
ORDER BY cap_difference DESC;

-- Result:
-- Multiple records show large discrepancies between actual and calculated market cap.
-- Some differences reach billions or higher.
-- Conclusion:
-- Market capitalization values are not fully consistent with price and circulating supply,
-- indicating potential data inconsistencies or differences in data sources/timestamps.


-- =====================================================
-- PROFILING / ANOMALY CHECKS
-- =====================================================

-- 12. Suspicious / Outlier Value Check
-- Purpose: Detect extreme outliers in numeric fields

SELECT *
FROM `outstanding-map-490915-u5.crypto_silver.clean_crypto`
WHERE
  ABS(pct_change_1h) > 1000
  OR ABS(pct_change_24h) > 1000
  OR ABS(pct_change_7d) > 1000
  OR ABS(pct_change_30d) > 1000;

-- Result:
-- Some records contain extreme percentage changes (>1000%).
-- Conclusion:
-- Potential outliers exist and should be handled carefully in downstream analysis.


-- 13. Basic Statistics Profiling
-- Purpose: Profile numerical ranges for key financial metrics

SELECT
  MIN(price_usd) AS min_price_usd,
  MAX(price_usd) AS max_price_usd,
  AVG(price_usd) AS avg_price_usd,
  MIN(market_cap_usd) AS min_market_cap_usd,
  MAX(market_cap_usd) AS max_market_cap_usd,
  AVG(market_cap_usd) AS avg_market_cap_usd,
  MIN(volume_24h_usd) AS min_volume_24h_usd,
  MAX(volume_24h_usd) AS max_volume_24h_usd,
  AVG(volume_24h_usd) AS avg_volume_24h_usd
FROM `outstanding-map-490915-u5.crypto_silver.clean_crypto`;

-- Result:
-- price_usd ranges from 0.01 to 109861.0
-- market_cap_usd ranges from 0.02 to 712726163003.0
-- volume_24h_usd ranges from 0.01 to 47122466339.0
-- Conclusion:
-- The dataset contains a very wide range of values, which is expected for cryptocurrency data,
-- but indicates strong skewness and the presence of extreme values.


-- 14. Extreme Percentage Change Anomaly Check
-- Purpose: Identify records with unusually large percentage changes

SELECT
  coin_name,
  symbol,
  pct_change_1h,
  pct_change_24h,
  pct_change_7d,
  pct_change_30d
FROM `outstanding-map-490915-u5.crypto_silver.clean_crypto`
WHERE pct_change_30d IS NOT NULL
ORDER BY ABS(pct_change_30d) DESC
LIMIT 20;

-- Result:
-- Multiple records show extremely large percentage changes.
-- Examples include values above 1000% and even above 200000%.
-- Conclusion:
-- The dataset contains strong outliers in percentage-based metrics.
-- These values may distort averages, trends, and visualizations if not filtered or capped.


-- 15. Rank Distribution Profiling
-- Purpose: Understand how records are distributed across market rank tiers

SELECT
  CASE
    WHEN rank <= 100 THEN 'Top 100'
    WHEN rank <= 500 THEN '101-500'
    WHEN rank <= 1000 THEN '501-1000'
    ELSE '1000+'
  END AS rank_bucket,
  COUNT(*) AS coin_count
FROM `outstanding-map-490915-u5.crypto_silver.clean_crypto`
GROUP BY rank_bucket
ORDER BY coin_count DESC;

-- Result:
-- 1000+      = 3150
-- 501-1000   = 500
-- 101-500    = 400
-- Top 100    = 100
-- Conclusion:
-- The dataset is heavily skewed toward lower-ranked cryptocurrencies,
-- which likely contributes to higher volatility, missing values, and extreme outliers.