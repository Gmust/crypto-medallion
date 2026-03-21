-- Gold: assets with largest price change over a recent window (template).
-- TODO: Set project/dataset and align column names with crypto_silver.crypto_clean.

-- TODO: Replace table reference and date/price columns with your Silver schema.
WITH daily AS (
  SELECT
    symbol,
    price_date,
    close_price
  FROM `your-gcp-project.crypto_silver.crypto_clean`
  WHERE price_date IS NOT NULL
    AND close_price IS NOT NULL
),
ranked AS (
  SELECT
    symbol,
    price_date,
    close_price,
    LAG(close_price) OVER (
      PARTITION BY symbol ORDER BY price_date
    ) AS prev_close
  FROM daily
),
changes AS (
  SELECT
    symbol,
    price_date,
    close_price,
    prev_close,
    SAFE_DIVIDE(close_price - prev_close, prev_close) AS pct_change
  FROM ranked
  WHERE prev_close IS NOT NULL AND prev_close != 0
)
SELECT
  symbol,
  price_date,
  pct_change
FROM changes
-- TODO: Filter to the window you care about, e.g. last 7 days:
-- WHERE price_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
ORDER BY ABS(pct_change) DESC
LIMIT 50
;
