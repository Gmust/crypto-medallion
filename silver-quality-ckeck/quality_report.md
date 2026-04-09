# Data Quality Report

## Objective
The goal of this validation was to assess the quality of transformed cryptocurrency data after the Bronze to Silver transformation within the Medallion Architecture pipeline.

## Validation Performed
The following checks were performed:
- Row count comparison between Bronze and Silver
- Null value analysis across key columns
- Duplicate record detection
- Completeness validation using `is_complete_record`
- Record uniqueness verification
- Naming consistency checks (`coin_name` vs `symbol`)
- Business logic validation (supply and market relationships)
- Profiling and anomaly detection (statistics, outliers, distributions)

---

## Initial Validation Summary

- Bronze row count: **4150**
- Silver row count: **4150**
- No row loss was detected between Bronze and Silver.

This indicates that the transformation process preserved all source records and did not remove data unexpectedly.

At the current stage, the Silver dataset structure appears consistent and suitable for further validation and downstream analysis.

---

## Structural Validation Findings

### Null Value Analysis
No null values were found in key identifier columns:
- `record_id`
- `rank`
- `coin_name`
- `symbol`

However, several analytical columns contain missing values:
- `price_usd`: **1726**
- `pct_change_1h`: **547**
- `pct_change_24h`: **452**
- `pct_change_7d`: **454**
- `pct_change_30d`: **509**
- `volume_24h_usd`: **484**
- `total_supply`: **495**
- `market_cap_usd`: **410**

This indicates that while the dataset is structurally consistent, some market-related metrics are incomplete.

### Completeness Check
- `is_complete_record = TRUE`: **2262**
- `is_complete_record = FALSE`: **1888**

A significant portion of the dataset is only partially populated and may require filtering before analysis.

### Missing Value Percentages
- `price_usd`: **41.59%**
- `pct_change_1h`: **13.18%**
- `pct_change_24h`: **10.89%**
- `pct_change_7d`: **10.94%**
- `pct_change_30d`: **12.27%**
- `volume_24h_usd`: **11.66%**
- `total_supply`: **11.93%**
- `market_cap_usd`: **9.88%**

This confirms that the main data quality issue is missing analytical market metrics rather than structural incompleteness.

### Duplicate Records
No duplicate records were found based on:
- `record_id`
- `coin_name`
- `symbol`

### Record Uniqueness
- Total rows: **4150**
- Unique `record_id`: **4150**
- Duplicate `record_id`: **0**

Each record is uniquely identifiable within the dataset.

---

## Consistency Findings

### Coin Name vs Symbol
Some `coin_name` values are associated with more than one `symbol`, for example:
- `stacks`
- `worldcoin`

This indicates minor naming inconsistencies in the dataset.

### Symbol Reuse
Some symbols are reused across multiple coin names. Examples include:
- `MINT` (4 different coins)
- `CAT` (4)
- `EGG` (4)
- `MEME` (4)
- `BANK` (3)
- `SHIB` (3)

This indicates that `symbol` should not be treated as a globally unique identifier without additional validation.

---

## Profiling and Anomaly Findings

### Basic Statistics
Key financial metrics show a very wide range of values:

- `price_usd`: **0.01 → 109861.0**
- `market_cap_usd`: **0.02 → 712,726,163,003.0**
- `volume_24h_usd`: **0.01 → 47,122,466,339.0**

This is expected for cryptocurrency data but indicates strong skewness and the presence of extreme values.

### Extreme Percentage Changes
Several records exhibit extreme values in `pct_change_30d`, including:

- `shirtum`: **237,566.7%**
- `hector network`: **14,084.8%**
- `arcas`: **12,512.7%**
- `prux-coin`: **4,870.2%**

These values are not necessarily invalid, but they are highly anomalous and can significantly distort averages, trend analysis, and visualizations.

### Rank Distribution
The dataset is heavily concentrated in lower-ranked cryptocurrencies:

- `Top 100`: **100**
- `101–500`: **400**
- `501–1000`: **500**
- `1000+`: **3150**

This indicates that most records represent smaller, more volatile assets, which helps explain the observed missing values and anomalies.

---

## Business Logic Findings

### Negative Value Check
No negative values were found in key numerical fields:
- `price_usd`
- `market_cap_usd`
- `volume_24h_usd`
- `circulating_supply`
- `total_supply`

This confirms basic logical correctness of numeric data.

### Supply Consistency
Some records violate expected supply logic:
- `circulating_supply > total_supply`

This indicates inconsistencies in market metadata and should be treated as a business logic anomaly.

### Market Cap Consistency
Significant discrepancies were found between:
- `market_cap_usd`
- calculated value (`price_usd * circulating_supply`)

Differences in some cases reach millions or billions, suggesting:
- asynchronous data updates
- differences in data sources
- or inconsistencies in raw data

---

## Raw Data Observations

Inspection of the raw dataset (Bronze layer) shows that some source records contain:
- negative price values
- extremely large numerical values
- unusually high percentage changes

This highlights the importance of the Medallion Architecture:
- Bronze stores raw, unprocessed data
- Silver improves structural consistency and usability
- Gold prepares data for analytical consumption

---

## Data Quality Impact

- Missing values in analytical columns may affect aggregations and visualizations.
- Extreme outliers can distort trends and averages.
- Naming inconsistencies complicate entity identification.
- Business logic inconsistencies (supply and market cap) may impact financial analysis.

Proper filtering, preprocessing, and validation are recommended before building analytical outputs.

---

## Final Conclusion

The Silver dataset is structurally sound:
- no data loss
- no duplicates
- complete key identifiers

However:
- analytical fields contain missing values
- extreme outliers are present
- some business logic inconsistencies exist

The dataset is suitable for downstream analysis and visualization, provided that null values, outliers, and inconsistencies are properly handled.