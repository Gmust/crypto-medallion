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

FROM daily_stats;