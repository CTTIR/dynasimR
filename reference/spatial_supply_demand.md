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

## Examples

``` r
set.seed(1)
runs <- data.frame(
  scenario        = rep(c("B-S00", "B-S01"), each = 20),
  replication     = rep(1:20, 2),
  completion_rate = c(stats::runif(20, 0.5, 0.7), stats::runif(20, 0.6, 0.8)),
  cost            = c(stats::runif(20, 900, 1100), stats::runif(20, 1000, 1300)),
  region          = rep(c("North", "South", "East", "West"), 10),
  supply          = stats::runif(40, 80, 120),
  demand          = stats::runif(40, 80, 120)
)
spatial_supply_demand(runs)
#> # A tibble: 4 × 9
#>   region supply_median demand_median sdi_median sdi_q025 sdi_q975 n_observed
#>   <chr>          <dbl>         <dbl>      <dbl>    <dbl>    <dbl>      <int>
#> 1 East            96.9         100.       0.973    0.862     1.13         10
#> 2 North          106.          102.       1.00     0.846     1.37         10
#> 3 South           95.3         100.       0.931    0.842     1.09         10
#> 4 West           102.           89.4      1.05     0.907     1.30         10
#> # ℹ 2 more variables: n_zero_demand <int>, undersupply <lgl>
```
