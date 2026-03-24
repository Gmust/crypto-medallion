-- ============================================================================
-- GOLD LAYER: Daily Top Movers (Price Change Leaders)
-- ============================================================================
-- Purpose:
--   Identify coins with the largest price movements in different timeframes.
--   Useful for volatility analysis and trading signals.
--
-- Source: crypto_silver.clean_crypto
-- Target: crypto_gold.daily_top_movers
-- ============================================================================

CREATE OR REPLACE TABLE `outstanding-map-490915-u5.crypto_gold.daily_top_movers` AS

WITH ranked_coins AS (
  SELECT
    DATE(loaded_at) AS trading_date,
    rank,
    coin_name,
    symbol,
    price_usd,
    market_cap_usd,
    
    -- 24-hour metrics
    pct_change_24h,
    ABS(pct_change_24h) AS abs_change_24h,
    
    -- 7-day metrics
    pct_change_7d,
    ABS(pct_change_7d) AS abs_change_7d,
    
    -- 30-day metrics
    pct_change_30d,
    ABS(pct_change_30d) AS abs_change_30d,
    
    -- ====================================================================
    -- RANKING: Top movers by 24-hour absolute change
    -- ====================================================================
    ROW_NUMBER() OVER (
      PARTITION BY DATE(loaded_at)
      ORDER BY ABS(pct_change_24h) DESC
    ) AS top_mover_rank_24h,
    
    -- ====================================================================
    -- RANKING: Top movers by 7-day absolute change
    -- ====================================================================
    ROW_NUMBER() OVER (
      PARTITION BY DATE(loaded_at)
      ORDER BY ABS(pct_change_7d) DESC
    ) AS top_mover_rank_7d,
    
    -- ====================================================================
    -- PERCENTILE RANK (for "top X%" queries)
    -- ====================================================================
    PERCENT_RANK() OVER (
      PARTITION BY DATE(loaded_at)
      ORDER BY ABS(pct_change_24h)
    ) AS percentile_24h
  
  FROM `outstanding-map-490915-u5.crypto_silver.clean_crypto`
  WHERE is_complete_record = TRUE
)

SELECT
  trading_date,
  rank,
  coin_name,
  symbol,
  ROUND(price_usd, 4) AS price_usd,
  ROUND(market_cap_usd, 2) AS market_cap_usd,
  
  -- ======================================================================
  -- 24-HOUR METRICS
  -- ======================================================================
  ROUND(pct_change_24h, 2) AS pct_change_24h,
  ROUND(abs_change_24h, 2) AS abs_change_24h,
  top_mover_rank_24h,
  
  CASE
    WHEN pct_change_24h > 10 THEN 'Strong Gainer'
    WHEN pct_change_24h > 0 THEN 'Gainer'
    WHEN pct_change_24h < -10 THEN 'Strong Loser'
    WHEN pct_change_24h < 0 THEN 'Loser'
    ELSE 'Neutral'
  END AS direction_24h,
  
  CASE
    WHEN ABS(pct_change_24h) > 20 THEN 'Extreme'
    WHEN ABS(pct_change_24h) > 10 THEN 'High'
    WHEN ABS(pct_change_24h) > 5 THEN 'Medium'
    ELSE 'Low'
  END AS volatility_level_24h,
  
  -- ======================================================================
  -- 7-DAY METRICS
  -- ======================================================================
  ROUND(pct_change_7d, 2) AS pct_change_7d,
  ROUND(abs_change_7d, 2) AS abs_change_7d,
  top_mover_rank_7d,
  
  CASE
    WHEN pct_change_7d > 50 THEN 'Extreme Gainer'
    WHEN pct_change_7d > 20 THEN 'Strong Gainer'
    WHEN pct_change_7d > 0 THEN 'Gainer'
    WHEN pct_change_7d < -50 THEN 'Extreme Loser'
    WHEN pct_change_7d < -20 THEN 'Strong Loser'
    WHEN pct_change_7d < 0 THEN 'Loser'
    ELSE 'Neutral'
  END AS direction_7d,
  
  -- ======================================================================
  -- 30-DAY METRICS
  -- ======================================================================
  ROUND(pct_change_30d, 2) AS pct_change_30d,
  ROUND(abs_change_30d, 2) AS abs_change_30d,
  
  CURRENT_TIMESTAMP() AS gold_created_at

FROM ranked_coins

WHERE abs_change_24h IS NOT NULL

ORDER BY
  trading_date DESC,
  abs_change_24h DESC,
  coin_name ASC;