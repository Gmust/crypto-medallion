-- ============================================================================
-- GOLD LAYER: Daily Market Summary
-- ============================================================================
-- Purpose:
--   Aggregate market-wide statistics for each trading date.
--   Provides quick insights into overall market health and sentiment.
--
-- Source: crypto_silver.clean_crypto
-- Target: crypto_gold.daily_summary
-- ============================================================================

CREATE OR REPLACE TABLE `outstanding-map-490915-u5.crypto_gold.daily_summary` AS

WITH daily_stats AS (
  SELECT
    DATE(loaded_at) AS trading_date,
    
    -- ====================================================================
    -- COUNT AGGREGATIONS
    -- ====================================================================
    COUNT(DISTINCT coin_name) AS total_coins,
    COUNTIF(pct_change_24h > 0) AS coins_gained_24h,
    COUNTIF(pct_change_24h < 0) AS coins_lost_24h,
    COUNTIF(pct_change_24h = 0) AS coins_unchanged_24h,
    COUNTIF(pct_change_24h > 10) AS extreme_gainers_24h,
    COUNTIF(pct_change_24h < -10) AS extreme_losers_24h,
    
    COUNTIF(pct_change_7d > 0) AS coins_gained_7d,
    COUNTIF(pct_change_7d < 0) AS coins_lost_7d,
    
    COUNTIF(pct_change_30d > 0) AS coins_gained_30d,
    COUNTIF(pct_change_30d < 0) AS coins_lost_30d,
    
    -- ====================================================================
    -- PRICE CHANGE STATISTICS (24h)
    -- ====================================================================
    ROUND(AVG(pct_change_24h), 2) AS avg_pct_change_24h,
    ROUND(MIN(pct_change_24h), 2) AS min_pct_change_24h,
    ROUND(MAX(pct_change_24h), 2) AS max_pct_change_24h,
    ROUND(STDDEV_POP(pct_change_24h), 2) AS stddev_pct_change_24h,
    ROUND(
      APPROX_QUANTILES(pct_change_24h, 100)[OFFSET(50)],
      2
    ) AS median_pct_change_24h,
    
    -- ====================================================================
    -- PRICE CHANGE STATISTICS (7d)
    -- ====================================================================
    ROUND(AVG(pct_change_7d), 2) AS avg_pct_change_7d,
    ROUND(MIN(pct_change_7d), 2) AS min_pct_change_7d,
    ROUND(MAX(pct_change_7d), 2) AS max_pct_change_7d,
    ROUND(STDDEV_POP(pct_change_7d), 2) AS stddev_pct_change_7d,
    
    -- ====================================================================
    -- MARKET CAP STATISTICS
    -- ====================================================================
    ROUND(SUM(market_cap_usd), 2) AS total_market_cap,
    ROUND(AVG(market_cap_usd), 2) AS avg_market_cap_per_coin,
    ROUND(MAX(market_cap_usd), 2) AS largest_market_cap,
    ROUND(MIN(market_cap_usd), 2) AS smallest_market_cap,
    
    -- ====================================================================
    -- TRADING VOLUME STATISTICS
    -- ====================================================================
    ROUND(SUM(volume_24h_usd), 2) AS total_volume_24h,
    ROUND(AVG(volume_24h_usd), 2) AS avg_volume_24h_per_coin
  
  FROM `outstanding-map-490915-u5.crypto_silver.clean_crypto`
  WHERE is_complete_record = TRUE
  GROUP BY trading_date
)

SELECT
  trading_date,
  
  -- ======================================================================
  -- COUNTS
  -- ======================================================================
  total_coins,
  coins_gained_24h,
  coins_lost_24h,
  coins_unchanged_24h,
  extreme_gainers_24h,
  extreme_losers_24h,
  
  -- ======================================================================
  -- MARKET SENTIMENT (as percentages)
  -- ======================================================================
  CASE
    WHEN total_coins > 0
      THEN ROUND(100.0 * coins_gained_24h / total_coins, 1)
    ELSE 0
  END AS pct_coins_gained_24h,
  
  CASE
    WHEN total_coins > 0
      THEN ROUND(100.0 * coins_lost_24h / total_coins, 1)
    ELSE 0
  END AS pct_coins_lost_24h,
  
  -- Sentiment score: -100 (all losers) to +100 (all gainers)
  CASE
    WHEN total_coins > 0
      THEN ROUND(
        100.0 * (coins_gained_24h - coins_lost_24h) / total_coins,
        1
      )
    ELSE 0
  END AS market_sentiment_score_24h,
  
  -- ======================================================================
  -- PRICE CHANGE METRICS (24h)
  -- ======================================================================
  avg_pct_change_24h,
  min_pct_change_24h,
  max_pct_change_24h,
  stddev_pct_change_24h,
  median_pct_change_24h,
  ROUND(max_pct_change_24h - min_pct_change_24h, 2) AS range_pct_change_24h,
  
  -- ======================================================================
  -- PRICE CHANGE METRICS (7d)
  -- ======================================================================
  avg_pct_change_7d,
  min_pct_change_7d,
  max_pct_change_7d,
  stddev_pct_change_7d,
  
  -- ======================================================================
  -- MARKET CAP METRICS
  -- ======================================================================
  total_market_cap,
  avg_market_cap_per_coin,
  largest_market_cap,
  smallest_market_cap,
  
  -- ======================================================================
  -- TRADING VOLUME
  -- ======================================================================
  total_volume_24h,
  avg_volume_24h_per_coin,
  
  -- ======================================================================
  -- DERIVED INSIGHTS: Market Health
  -- ======================================================================
  CASE
    WHEN ROUND(100.0 * coins_gained_24h / total_coins, 1) > 60 THEN 'Bullish'
    WHEN ROUND(100.0 * coins_gained_24h / total_coins, 1) > 40 THEN 'Mixed'
    WHEN ROUND(100.0 * coins_gained_24h / total_coins, 1) > 20 THEN 'Bearish'
    ELSE 'Strongly Bearish'
  END AS market_health_24h,
  
  CASE
    WHEN stddev_pct_change_24h > 10 THEN 'Extreme Volatility'
    WHEN stddev_pct_change_24h > 5 THEN 'High Volatility'
    WHEN stddev_pct_change_24h > 2 THEN 'Moderate Volatility'
    ELSE 'Low Volatility'
  END AS volatility_classification,
  
  CURRENT_TIMESTAMP() AS gold_created_at

FROM daily_stats

ORDER BY trading_date DESC;