-- Silver: cleaned copy of Bronze cryptocurrency data.
-- TODO: Replace `your-gcp-project` and placeholder backtick column names with real Bronze columns.
-- Preview Bronze with: SELECT * FROM `your-gcp-project.crypto_bronze.crypto_raw` LIMIT 5;

CREATE OR REPLACE TABLE `your-gcp-project.crypto_silver.crypto_clean` AS
SELECT DISTINCT
  -- TODO: Rename `YOUR_SYMBOL_COL` etc. to match your Kaggle CSV headers in Bronze (use backticks if needed).
  SAFE_CAST(t.`YOUR_SYMBOL_COL` AS STRING) AS symbol,
  SAFE_CAST(t.`YOUR_DATE_COL` AS DATE) AS price_date,
  SAFE_CAST(t.`YOUR_OPEN_COL` AS FLOAT64) AS open_price,
  SAFE_CAST(t.`YOUR_HIGH_COL` AS FLOAT64) AS high_price,
  SAFE_CAST(t.`YOUR_LOW_COL` AS FLOAT64) AS low_price,
  SAFE_CAST(t.`YOUR_CLOSE_COL` AS FLOAT64) AS close_price,
  SAFE_CAST(t.`YOUR_VOLUME_COL` AS FLOAT64) AS volume
FROM `your-gcp-project.crypto_bronze.crypto_raw` AS t
WHERE
  t.`YOUR_SYMBOL_COL` IS NOT NULL
  AND t.`YOUR_DATE_COL` IS NOT NULL
;

-- If placeholders are still present, this query will error until you edit column names.
-- After it runs, compare row counts to Bronze and validate types.
