-- Gold: per-symbol daily summary metrics (template).
-- TODO: Replace project/dataset/table and columns with your Silver definitions.

CREATE OR REPLACE TABLE `your-gcp-project.crypto_gold.daily_summary` AS
SELECT
  symbol,
  price_date,
  COUNT(*) AS row_count,  -- TODO: remove or adjust if one row per symbol/day
  AVG(close_price) AS avg_close,
  MIN(low_price) AS min_low,
  MAX(high_price) AS max_high,
  SUM(volume) AS total_volume
FROM `your-gcp-project.crypto_silver.crypto_clean`
WHERE
  symbol IS NOT NULL
  AND price_date IS NOT NULL
GROUP BY symbol, price_date
;
