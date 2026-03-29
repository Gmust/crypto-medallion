# Gold Layer

## Purpose

Gold contains **aggregated, analysis-ready** tables built from Silver. Typical steps:

- Business logic and KPIs (e.g., market sentiment, risk scores)
- Aggregations and rankings (e.g., top movers, daily summaries)
- Reporting-friendly denormalization
- Heavy filtering (e.g., only complete records)

## What Gold is not

- **Not** a replacement for ad-hoc SQL; use these tables for **repeatable analytics**.
- **Not** meant for real-time queries; refresh on a schedule (e.g., daily).

## Tables Overview

| Table | Rows | Purpose | Refresh |
|-------|------|---------|---------|
| `daily_top_movers` | ~2,100+ | Identify largest price movements | Daily |
| `daily_summary` | 1 per date | Market-wide metrics & sentiment | Daily |
| `volatility_analysis` | ~2,260+ | Risk assessment per coin | Daily |

---

## 1. daily_top_movers

**Source:** `crypto_silver.clean_crypto`

**Purpose:** Identify cryptocurrencies with the largest price movements across timeframes. Used for volatility analysis, trading signals, and market alerts.

### Columns

| Column | Type | Description |
|--------|------|-------------|
| trading_date | DATE | Date of trading activity |
| rank | INT64 | Cryptocurrency ranking |
| coin_name | STRING | Coin name (lowercase) |
| symbol | STRING | Ticker symbol (uppercase) |
| price_usd | FLOAT64 | Current price in USD |
| market_cap_usd | FLOAT64 | Market capitalization in USD |
| pct_change_24h | FLOAT64 | Price change % (24 hours) |
| abs_change_24h | FLOAT64 | Absolute price change % (24 hours) |
| top_mover_rank_24h | INT64 | Ranking by 24h absolute change (1 = highest) |
| direction_24h | STRING | Strong Gainer / Gainer / Loser / Strong Loser / Neutral |
| volatility_level_24h | STRING | Extreme / High / Medium / Low |
| pct_change_7d | FLOAT64 | Price change % (7 days) |
| abs_change_7d | FLOAT64 | Absolute price change % (7 days) |
| top_mover_rank_7d | INT64 | Ranking by 7d absolute change |
| direction_7d | STRING | Extreme Gainer / Strong Gainer / Gainer / Loser / Strong Loser / Extreme Loser / Neutral |
| pct_change_30d | FLOAT64 | Price change % (30 days) |
| abs_change_30d | FLOAT64 | Absolute price change % (30 days) |
| gold_created_at | TIMESTAMP | When this record was created |

### Key Classifications

**direction_24h:**
- Strong Gainer: > 10% gain
- Gainer: 0% to 10% gain
- Loser: 0% to -10% loss
- Strong Loser: < -10% loss
- Neutral: 0% change

**volatility_level_24h:**
- Extreme: > 20%
- High: 10-20%
- Medium: 5-10%
- Low: < 5%

### Sample Queries

```sql
-- Top 10 gainers in last 24 hours
SELECT
  coin_name,
  symbol,
  pct_change_24h,
  market_cap_usd,
  direction_24h,
  volatility_level_24h
FROM `outstanding-map-490915-u5.crypto_gold.daily_top_movers`
WHERE trading_date = CURRENT_DATE()
AND pct_change_24h > 0
ORDER BY pct_change_24h DESC
LIMIT 10;
```

```sql
-- Top 10 losers in last 24 hours
SELECT
  coin_name,
  symbol,
  pct_change_24h,
  market_cap_usd,
  direction_24h
FROM `outstanding-map-490915-u5.crypto_gold.daily_top_movers`
WHERE trading_date = CURRENT_DATE()
AND pct_change_24h < 0
ORDER BY pct_change_24h ASC
LIMIT 10;
```

```sql
-- Extreme movers (>20% in 24h)
SELECT
  coin_name,
  symbol,
  pct_change_24h,
  pct_change_7d,
  market_cap_usd,
  volatility_level_24h
FROM `outstanding-map-490915-u5.crypto_gold.daily_top_movers`
WHERE trading_date = CURRENT_DATE()
AND abs_change_24h > 20
ORDER BY abs_change_24h DESC;
```

---

## 2. daily_summary

**Source:** `crypto_silver.clean_crypto`

**Purpose:** Aggregate market-wide metrics and sentiment. Quick answer to "What's the overall health of the crypto market today?"

### Columns

| Column | Type | Description |
|--------|------|-------------|
| trading_date | DATE | Trading date |
| total_coins | INT64 | Total number of coins analyzed |
| coins_gained_24h | INT64 | Count of coins with positive 24h change |
| coins_lost_24h | INT64 | Count of coins with negative 24h change |
| coins_unchanged_24h | INT64 | Count of coins with zero 24h change |
| extreme_gainers_24h | INT64 | Count of coins with >10% gain in 24h |
| extreme_losers_24h | INT64 | Count of coins with <-10% loss in 24h |
| pct_coins_gained_24h | FLOAT64 | % of coins that gained in 24h |
| pct_coins_lost_24h | FLOAT64 | % of coins that lost in 24h |
| market_sentiment_score_24h | FLOAT64 | Sentiment score (-100 to +100) |
| avg_pct_change_24h | FLOAT64 | Average price change % across all coins (24h) |
| min_pct_change_24h | FLOAT64 | Minimum price change % (24h) |
| max_pct_change_24h | FLOAT64 | Maximum price change % (24h) |
| stddev_pct_change_24h | FLOAT64 | Standard deviation of price changes (24h volatility) |
| median_pct_change_24h | FLOAT64 | Median price change % (24h) |
| range_pct_change_24h | FLOAT64 | Range (max - min) of price changes (24h) |
| avg_pct_change_7d | FLOAT64 | Average price change % across all coins (7d) |
| min_pct_change_7d | FLOAT64 | Minimum price change % (7d) |
| max_pct_change_7d | FLOAT64 | Maximum price change % (7d) |
| stddev_pct_change_7d | FLOAT64 | Standard deviation of price changes (7d volatility) |
| total_market_cap | FLOAT64 | Sum of all market caps (USD) |
| avg_market_cap_per_coin | FLOAT64 | Average market cap per coin (USD) |
| largest_market_cap | FLOAT64 | Largest single coin market cap (USD) |
| smallest_market_cap | FLOAT64 | Smallest single coin market cap (USD) |
| total_volume_24h | FLOAT64 | Total trading volume (USD) |
| avg_volume_24h_per_coin | FLOAT64 | Average trading volume per coin (USD) |
| market_health_24h | STRING | Bullish / Mixed / Bearish / Strongly Bearish |
| volatility_classification | STRING | Low / Moderate / High / Extreme Volatility |
| gold_created_at | TIMESTAMP | When this record was created |

### Key Classifications

**market_sentiment_score_24h** (Range: -100 to +100):
- +100: All coins gained
- 0: Equal gainers and losers
- -100: All coins lost

**market_health_24h** (Based on % of gainers):
- Bullish: > 60% gained
- Mixed: 40-60% gained
- Bearish: 20-40% gained
- Strongly Bearish: < 20% gained

**volatility_classification** (Based on stddev):
- Extreme Volatility: stddev > 10%
- High Volatility: stddev 5-10%
- Moderate Volatility: stddev 2-5%
- Low Volatility: stddev < 2%

### Sample Queries

```sql
-- Daily market summary
SELECT
  trading_date,
  total_coins,
  coins_gained_24h,
  coins_lost_24h,
  pct_coins_gained_24h,
  pct_coins_lost_24h,
  market_sentiment_score_24h,
  market_health_24h,
  avg_pct_change_24h,
  stddev_pct_change_24h,
  volatility_classification,
  total_market_cap
FROM `outstanding-map-490915-u5.crypto_gold.daily_summary`
ORDER BY trading_date DESC
LIMIT 1;
```

```sql
-- Market sentiment trend (last 7 days)
SELECT
  trading_date,
  market_sentiment_score_24h,
  market_health_24h,
  pct_coins_gained_24h,
  pct_coins_lost_24h,
  volatility_classification
FROM `outstanding-map-490915-u5.crypto_gold.daily_summary`
WHERE trading_date >= CURRENT_DATE() - 7
ORDER BY trading_date DESC;
```

```sql
-- Market health metrics
SELECT
  trading_date,
  total_coins,
  extreme_gainers_24h,
  extreme_losers_24h,
  avg_pct_change_24h,
  stddev_pct_change_24h,
  total_market_cap
FROM `outstanding-map-490915-u5.crypto_gold.daily_summary`
WHERE trading_date = CURRENT_DATE();
```

---

## 3. volatility_analysis

**Source:** `crypto_silver.clean_crypto`

**Purpose:** Measure price volatility and risk per coin. Used for portfolio risk assessment, identifying stable vs. high-risk coins, and trend analysis.

### Columns

| Column | Type | Description |
|--------|------|-------------|
| trading_date | DATE | Date of trading activity |
| rank | INT64 | Cryptocurrency ranking |
| coin_name | STRING | Coin name (lowercase) |
| symbol | STRING | Ticker symbol (uppercase) |
| price_usd | FLOAT64 | Current price in USD |
| market_cap_usd | FLOAT64 | Market capitalization in USD |
| pct_change_1h | FLOAT64 | Price change % (1 hour) |
| pct_change_24h | FLOAT64 | Price change % (24 hours) |
| pct_change_7d | FLOAT64 | Price change % (7 days) |
| pct_change_30d | FLOAT64 | Price change % (30 days) |
| abs_change_1h | FLOAT64 | Absolute price change % (1 hour) |
| abs_change_24h | FLOAT64 | Absolute price change % (24 hours) |
| abs_change_7d | FLOAT64 | Absolute price change % (7 days) |
| abs_change_30d | FLOAT64 | Absolute price change % (30 days) |
| max_abs_change_all_timeframes | FLOAT64 | Largest absolute move across all time periods |
| risk_category | STRING | Extreme / High / Moderate / Low Risk |
| risk_score | FLOAT64 | Composite risk score (0-100, higher = riskier) |
| trend_classification | STRING | Consistent Uptrend / Downtrend / Short-term Rebound / Pullback / Mixed Trend |
| gold_created_at | TIMESTAMP | When this record was created |

### Key Classifications

**risk_category** (Based on multi-timeframe changes):
- Extreme Risk: 24h > 20% OR 7d > 50% OR 30d > 100%
- High Risk: 24h > 10% OR 7d > 25%
- Moderate Risk: 24h > 5% OR 7d > 10%
- Low Risk: Otherwise

**risk_score** (0-100 composite score):
- 25% weight on 24h volatility
- 35% weight on 7d volatility
- 25% weight on 30d volatility
- 15% penalty if 24h change is negative
- Higher score = Higher risk

**trend_classification** (Multi-timeframe trend):
- Consistent Uptrend: All timeframes positive
- Consistent Downtrend: All timeframes negative
- Short-term Rebound: 24h positive, 7d negative
- Short-term Pullback: 24h negative, 7d positive
- Mixed Trend: Other combinations

### Sample Queries

```sql
-- High-risk coins today
SELECT
  coin_name,
  symbol,
  price_usd,
  pct_change_24h,
  pct_change_7d,
  pct_change_30d,
  risk_score,
  risk_category,
  trend_classification
FROM `outstanding-map-490915-u5.crypto_gold.volatility_analysis`
WHERE trading_date = CURRENT_DATE()
AND risk_score > 50
ORDER BY risk_score DESC
LIMIT 20;
```

```sql
-- Stable coins (low risk)
SELECT
  coin_name,
  symbol,
  price_usd,
  market_cap_usd,
  pct_change_24h,
  pct_change_7d,
  risk_score,
  risk_category
FROM `outstanding-map-490915-u5.crypto_gold.volatility_analysis`
WHERE trading_date = CURRENT_DATE()
AND risk_score < 20
ORDER BY market_cap_usd DESC
LIMIT 20;
```

```sql
-- Extreme movers today (>20% in 24h)
SELECT
  coin_name,
  symbol,
  pct_change_24h,
  pct_change_7d,
  risk_category,
  trend_classification
FROM `outstanding-map-490915-u5.crypto_gold.volatility_analysis`
WHERE trading_date = CURRENT_DATE()
AND abs_change_24h > 20
ORDER BY abs_change_24h DESC;
```

```sql
-- Uptrend coins (consistent multi-timeframe gains)
SELECT
  coin_name,
  symbol,
  pct_change_24h,
  pct_change_7d,
  pct_change_30d,
  market_cap_usd,
  risk_category
FROM `outstanding-map-490915-u5.crypto_gold.volatility_analysis`
WHERE trading_date = CURRENT_DATE()
AND trend_classification = 'Consistent Uptrend'
ORDER BY pct_change_30d DESC;
```

---

## Business Use Cases

### 📊 Dashboard: Market Health Monitor
Use `daily_summary` to build:
- **Market sentiment gauge** — KPI card showing sentiment score (-100 to +100)
- **Gainers vs. Losers pie chart** — % coins gained vs. lost
- **Price change distribution** — Histogram of changes across all coins
- **Volatility trend** — Line chart of stddev over time
- **Total market cap** — KPI card with total capitalization

### 📈 Report: Top Movers Alert
Use `daily_top_movers` to identify:
- **Daily top 10 gainers/losers** — Show coin name, % change, volume
- **Extreme moves (>20% in 24h)** — Alert on unusual activity
- **Coins with rising volatility** — Track volatility_level_24h over time (red flags)
- **Compare gainers vs losers** — Separate analysis for performance patterns

### ⚠️ Risk Assessment for Portfolio
Use `volatility_analysis` for:
- **Portfolio risk evaluation** — Filter by risk_score range, aggregate
- **Identify stable coins** — risk_category = 'Low Risk' for conservative portfolios
- **Spot emerging trends** — Watch trend_classification changes (e.g., Rebound vs. Pullback)
- **Risk-adjusted returns** — Pair with price_usd and pct_change_* columns

### 🔍 Comparative Analysis

```sql
-- Compare 24h movers by category
SELECT
  direction_24h,
  COUNT(*) AS count,
  ROUND(AVG(pct_change_24h), 2) AS avg_change,
  ROUND(MAX(pct_change_24h), 2) AS max_change,
  ROUND(MIN(pct_change_24h), 2) AS min_change,
  ROUND(AVG(market_cap_usd), 2) AS avg_market_cap
FROM `outstanding-map-490915-u5.crypto_gold.daily_top_movers`
WHERE trading_date = CURRENT_DATE()
GROUP BY direction_24h
ORDER BY avg_change DESC;
```

```sql
-- Risk distribution across portfolio
SELECT
  risk_category,
  COUNT(*) AS coin_count,
  ROUND(AVG(risk_score), 2) AS avg_risk_score,
  ROUND(AVG(market_cap_usd), 2) AS avg_market_cap
FROM `outstanding-map-490915-u5.crypto_gold.volatility_analysis`
WHERE trading_date = CURRENT_DATE()
GROUP BY risk_category
ORDER BY avg_risk_score DESC;
```

---