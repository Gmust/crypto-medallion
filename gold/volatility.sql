-- ============================================================================
-- GOLD LAYER: Volatility Analysis
-- ============================================================================
-- Purpose:
--   Measure price volatility per coin across multiple timeframes.
--   Identifies high-risk and stable coins for portfolio planning.
--
-- Source: crypto_silver.clean_crypto
-- Target: crypto_gold.volatility_analysis
-- ============================================================================

CREATE OR REPLACE TABLE `outstanding-map-490915-u5.crypto_gold.volatility_analysis` AS

SELECT
  DATE(loaded_at) AS trading_date,
  rank,
  coin_name,
  symbol,
  ROUND(price_usd, 4) AS price_usd,
  ROUND(market_cap_usd, 2) AS market_cap_usd,
  
  -- ======================================================================
  -- DAILY PRICE CHANGES
  -- ======================================================================
  ROUND(COALESCE(pct_change_1h, 0), 2) AS pct_change_1h,
  ROUND(pct_change_24h, 2) AS pct_change_24h,
  ROUND(pct_change_7d, 2) AS pct_change_7d,
  ROUND(pct_change_30d, 2) AS pct_change_30d,
  
  -- ======================================================================
  -- MULTI-TIMEFRAME VOLATILITY (Absolute Changes)
  -- ======================================================================
  ROUND(ABS(COALESCE(pct_change_1h, 0)), 2) AS abs_change_1h,
  ROUND(ABS(pct_change_24h), 2) AS abs_change_24h,
  ROUND(ABS(pct_change_7d), 2) AS abs_change_7d,
  ROUND(ABS(pct_change_30d), 2) AS abs_change_30d,
  
  -- Max absolute change across all timeframes
  ROUND(
    GREATEST(
      ABS(COALESCE(pct_change_1h, 0)),
      ABS(pct_change_24h),
      ABS(pct_change_7d),
      ABS(pct_change_30d)
    ),
    2
  ) AS max_abs_change_all_timeframes,
  
  -- ======================================================================
  -- VOLATILITY CLASSIFICATION (Risk Levels)
  -- ======================================================================
  CASE
    WHEN ABS(pct_change_24h) > 20
      OR ABS(pct_change_7d) > 50
      OR ABS(pct_change_30d) > 100
      THEN 'Extreme Risk'
    WHEN ABS(pct_change_24h) > 10
      OR ABS(pct_change_7d) > 25
      THEN 'High Risk'
    WHEN ABS(pct_change_24h) > 5
      OR ABS(pct_change_7d) > 10
      THEN 'Moderate Risk'
    ELSE 'Low Risk'
  END AS risk_category,
  
  -- ======================================================================
  -- TREND DIRECTION (Multi-timeframe Analysis)
  -- ======================================================================
  CASE
    WHEN pct_change_24h > 0 AND pct_change_7d > 0 AND pct_change_30d > 0
      THEN 'Consistent Uptrend'
    WHEN pct_change_24h < 0 AND pct_change_7d < 0 AND pct_change_30d < 0
      THEN 'Consistent Downtrend'
    WHEN pct_change_24h > 0 AND pct_change_7d < 0
      THEN 'Short-term Rebound'
    WHEN pct_change_24h < 0 AND pct_change_7d > 0
      THEN 'Short-term Pullback'
    ELSE 'Mixed Trend'
  END AS trend_classification,
  
  -- ======================================================================
  -- COMPOSITE RISK SCORE (0-100)
  -- ======================================================================
  ROUND(
    LEAST(100,
      (ABS(pct_change_24h) / 20 * 25) +           -- 25% weight on 24h volatility
      (ABS(pct_change_7d) / 50 * 35) +            -- 35% weight on 7d volatility
      (ABS(pct_change_30d) / 100 * 25) +          -- 25% weight on 30d volatility
      (CASE WHEN pct_change_24h < 0 THEN 15 ELSE 0 END)  -- 15% if negative 24h
    ),
    2
  ) AS risk_score,
  
  CURRENT_TIMESTAMP() AS gold_created_at

FROM `outstanding-map-490915-u5.crypto_silver.clean_crypto`

WHERE is_complete_record = TRUE

ORDER BY
  trading_date DESC,
  risk_score DESC,
  coin_name ASC;