-- ============================================================================
-- SILVER LAYER: Clean Cryptocurrency Data
-- ============================================================================
-- Purpose:
--   Transform raw Bronze data into clean, typed, analysis-ready format.
--   Handles column name standardization, type casting, string parsing.
--   Does NOT apply business logic or aggregations (those belong in Gold).
--
-- Source: crypto_bronze.raw_crypto
-- Target: crypto_silver.clean_crypto
--
-- Usage:
--   1. Verify Bronze table and column names exist
--   2. Review all backtick column references below
--   3. Run this query to create/replace Silver table
--   4. Validate: SELECT COUNT(*), DESCRIBE crypto_silver.clean_crypto
-- ============================================================================

CREATE OR REPLACE TABLE `outstanding-map-490915-u5.crypto_silver.clean_crypto` AS

WITH cleaned_data AS (
  SELECT
    -- ========================================================================
    -- IDENTIFIERS: Rank, Name, Symbol
    -- ========================================================================
    Rank AS rank,
    TRIM(LOWER(`Coin Name`)) AS coin_name,
    TRIM(UPPER(Symbol)) AS symbol,
    
    -- ========================================================================
    -- PRICE: Current USD price
    -- Remove $, commas, spaces and cast to FLOAT64
    -- ========================================================================
    SAFE_CAST(
      REGEXP_REPLACE(
        TRIM(` Price `),
        r'[$, ]',
        ''
      )
      AS FLOAT64
    ) AS price_usd,
    
    -- ========================================================================
    -- PRICE CHANGES: Multiple timeframes
    -- Remove % symbols and cast to FLOAT64
    -- Null values preserved (indicate no trading activity)
    -- ========================================================================
    SAFE_CAST(
      REGEXP_REPLACE(TRIM(`1h`), r'%', '')
      AS FLOAT64
    ) AS pct_change_1h,
    
    SAFE_CAST(
      REGEXP_REPLACE(TRIM(`24h`), r'%', '')
      AS FLOAT64
    ) AS pct_change_24h,
    
    SAFE_CAST(
      REGEXP_REPLACE(TRIM(`7d`), r'%', '')
      AS FLOAT64
    ) AS pct_change_7d,
    
    SAFE_CAST(
      REGEXP_REPLACE(TRIM(`30d`), r'%', '')
      AS FLOAT64
    ) AS pct_change_30d,
    
    -- ========================================================================
    -- VOLUME: 24-hour trading volume in USD
    -- Remove $, commas, spaces and cast to FLOAT64
    -- ========================================================================
    SAFE_CAST(
      REGEXP_REPLACE(
        TRIM(` 24h Volume `),
        r'[$, ]',
        ''
      )
      AS FLOAT64
    ) AS volume_24h_usd,
    
    -- ========================================================================
    -- SUPPLY: Circulating and Total
    -- Circulating Supply is already FLOAT64 in Bronze
    -- Total Supply needs "Million"/"Billion" suffix handling
    -- ========================================================================
    `Circulating Supply` AS circulating_supply,
    
    CASE
      WHEN TRIM(`Total Supply`) LIKE '%Million%'
        THEN SAFE_CAST(
          REGEXP_REPLACE(
            REGEXP_REPLACE(TRIM(`Total Supply`), r' Million', ''),
            r'[, ]',
            ''
          )
          AS FLOAT64
        ) * 1000000
      
      WHEN TRIM(`Total Supply`) LIKE '%Billion%'
        THEN SAFE_CAST(
          REGEXP_REPLACE(
            REGEXP_REPLACE(TRIM(`Total Supply`), r' Billion', ''),
            r'[, ]',
            ''
          )
          AS FLOAT64
        ) * 1000000000
      
      ELSE SAFE_CAST(
        REGEXP_REPLACE(TRIM(`Total Supply`), r'[, ]', '')
        AS FLOAT64
      )
    END AS total_supply,
    
    -- ========================================================================
    -- MARKET CAP: Market capitalization in USD
    -- Remove $, commas, spaces and cast to FLOAT64
    -- ========================================================================
    SAFE_CAST(
      REGEXP_REPLACE(
        TRIM(` Market Cap `),
        r'[$, ]',
        ''
      )
      AS FLOAT64
    ) AS market_cap_usd,
    
    -- ========================================================================
    -- TIMESTAMP: When this record was loaded
    -- Uses CURRENT_TIMESTAMP since Bronze has no timestamp column
    -- ========================================================================
    CURRENT_TIMESTAMP() AS loaded_at,
    
    -- ========================================================================
    -- DATA QUALITY FLAG
    -- is_complete_record = TRUE if all required fields are non-null
    -- Filtering on this flag happens in Gold layer, not here
    -- ========================================================================
    CASE
      WHEN `Coin Name` IS NULL
        OR SAFE_CAST(
          REGEXP_REPLACE(
            TRIM(` Price `),
            r'[$, ]',
            ''
          )
          AS FLOAT64
        ) IS NULL
        OR SAFE_CAST(
          REGEXP_REPLACE(
            TRIM(` Market Cap `),
            r'[$, ]',
            ''
          )
          AS FLOAT64
        ) IS NULL
        THEN FALSE
      ELSE TRUE
    END AS is_complete_record,
    
    -- ========================================================================
    -- AUDIT TRAIL
    -- Tracks who and when Silver table was created/refreshed
    -- ========================================================================
    CURRENT_TIMESTAMP() AS silver_created_at,
    'Outlines1' AS silver_created_by

  FROM `outstanding-map-490915-u5.crypto_bronze.raw_crypto`
)

SELECT
  -- Add surrogate key for traceability
  ROW_NUMBER() OVER (
    ORDER BY loaded_at DESC, coin_name ASC
  ) AS record_id,
  
  -- All cleaned columns
  rank,
  coin_name,
  symbol,
  price_usd,
  pct_change_1h,
  pct_change_24h,
  pct_change_7d,
  pct_change_30d,
  volume_24h_usd,
  circulating_supply,
  total_supply,
  market_cap_usd,
  loaded_at,
  is_complete_record,
  silver_created_at,
  silver_created_by

FROM cleaned_data

ORDER BY loaded_at DESC, coin_name ASC;