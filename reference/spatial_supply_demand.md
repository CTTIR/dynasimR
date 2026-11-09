# Supply-Demand Index (SDI) per region

Computes the ratio of available service capacity to positive demand.
Values \> 1 indicate oversupply, values \< 1 undersupply, and equal
supply and demand give exactly 1. Rows with zero demand have an
undefined ratio and are excluded from SDI summaries; a region with no
valid ratio has `NA` SDI and `NA` undersupply status.

## Usage

``` r
spatial_supply_demand(
  data,
  region_col = "region",
  supply_col = "supply",
  demand_col = "demand",
  eps = 1
)
```

## Arguments

- data:

  A `dynasimR_data` object or summary tibble with `region`, `supply` and
  `demand` columns. Observed supply and demand must be finite and
  nonnegative. Missing values are allowed.

- region_col:

  Character. Region column name. Default `"region"`.

- supply_col:

  Character. Supply column name. Default `"supply"`.

- demand_col:

  Character. Demand column name. Default `"demand"`.

- eps:

  Deprecated compatibility argument. No offset is applied: adding an
  offset changes the ratio even when demand is positive.

## Value

A tibble with the region column, `supply_median`, `demand_median`,
`sdi_median`, `sdi_q025`, `sdi_q975`, `undersupply`, `n_observed` (valid
paired ratios) and `n_zero_demand`. The interval is the observed 2.5th
to 97.5th percentile range, not a confidence interval for the median.
