# Data Quality Handoff

## Status
Data validation completed. The dataset is usable for visualization, but requires filtering of incomplete records and handling of outliers.

## Key Validation Summary
- No data loss between Bronze and Silver (row counts match)
- No duplicate records detected
- Key identifier columns are complete
- The dataset is structurally suitable for downstream analysis

## Recommended Tables for Visualization
Use the following Gold tables for charts and dashboards:

- `crypto_gold.volatility_analysis`
- `crypto_gold.daily_summary`
- `crypto_gold.daily_top_movers`

---

## Suggested Fields for Visualization

### `volatility_analysis`
Recommended fields:
- `coin_name`
- `symbol`
- `risk_score`
- `risk_category`
- `max_abs_change_all_timeframes`
- `trend_classification`

Useful for:
- Top risk coins
- Risk category distribution
- Trend classification charts

### `daily_summary`
Recommended fields:
- `trading_date`
- `total_coins`
- `coins_gained_24h`
- `coins_lost_24h`
- `pct_coins_gained_24h`
- `market_sentiment_score_24h`
- `avg_pct_change_24h`
- `stddev_pct_change_24h`
- `total_market_cap`
- `market_health_24h`
- `volatility_classification`

Useful for:
- Market sentiment trend
- Coins gained vs lost over time
- Volatility trend over time
- Total market cap trend

### `daily_top_movers`
Recommended fields:
- `coin_name`
- `symbol`
- `pct_change_24h`
- `pct_change_7d`
- `pct_change_30d`
- `direction_24h`
- `volatility_level_24h`

Useful for:
- Top gainers and losers
- Most volatile coins
- Short-term movement comparisons

---

## Recommended Data Filtering

For cleaner charts and more reliable presentation output:

- Prefer records where `is_complete_record = TRUE`
- Exclude records where key metrics are NULL
- Consider removing or capping extreme outliers (e.g. `% change > 1000%`)
- Validate chart axis ranges before finalizing visuals

---

## Important Data Caveats

### Incomplete Records
- Total records: **4150**
- Complete records: **2262**
- Incomplete records: **1888**

### Highest Missing Rates
- `price_usd`: **41.59%**
- `pct_change_1h`: **13.18%**
- `pct_change_30d`: **12.27%**
- `total_supply`: **11.93%**
- `volume_24h_usd`: **11.66%**
- `market_cap_usd`: **9.88%**

### Entity Labeling Warning
Some `coin_name` values map to multiple symbols, and some `symbol` values map to multiple coin names.

**Recommendation:**  
Do not use `symbol` alone as a unique identifier in charts, labels, or grouping logic.  
Prefer using both:
- `coin_name`
- `symbol`

---

## Suggested Visualizations

### From `volatility_analysis`
- Top 10 highest risk cryptocurrencies (bar chart)
- Risk category distribution (pie or bar chart)
- Trend classification distribution

### From `daily_summary`
- Market sentiment trend over time (line chart)
- Coins gained vs lost over time (stacked bar / line chart)
- Volatility classification over time
- Total market cap trend

### From `daily_top_movers`
- Top gainers and losers in 24h (bar chart)
- Most volatile movers (bar chart)
- 24h vs 7d movement comparison

---

## Final Note
The dataset is suitable for presentation-ready charts, dashboards, and analytical insights, provided that incomplete records, extreme outliers, and identifier inconsistencies are handled appropriately