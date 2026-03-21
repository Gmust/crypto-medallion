-- Gold: simple volatility-style metric using daily log returns (template).
-- TODO: Replace references; confirm price_date ordering and one row per symbol per day in Silver.

WITH ordered AS (
  SELECT
    symbol,
    price_date,
    close_price,
    LAG(close_price) OVER (PARTITION BY symbol ORDER BY price_date) AS prev_close
  FROM `your-gcp-project.crypto_silver.crypto_clean`
  WHERE close_price IS NOT NULL AND close_price > 0
),
returns AS (
  SELECT
    symbol,
    price_date,
    LN(close_price) - LN(prev_close) AS log_return
  FROM ordered
  WHERE prev_close IS NOT NULL AND prev_close > 0
)
-- Rolling stddev of log returns over N days per symbol (example N = 7).
SELECT
  symbol,
  price_date,
  STDDEV_SAMP(log_return) OVER (
    PARTITION BY symbol
    ORDER BY price_date
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ) AS rolling_volatility_7d
FROM returns
-- TODO: Materialize into a Gold table if needed:
-- CREATE OR REPLACE TABLE `your-gcp-project.crypto_gold.volatility` AS ...
