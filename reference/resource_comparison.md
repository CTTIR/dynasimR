# Compare outcomes across resource configurations

Aggregates primary outcome metrics (event rate, Compliance Index and -
if present - median time-to-first-service) by the `resource` column of
the joined scenario metadata.

## Usage

``` r
resource_comparison(
  data,
  scenarios = NULL,
  metrics = c("event_rate", "compliance_index")
)
```

## Arguments

- data:

  A `dynasimR_data` object or summary tibble.

- scenarios:

  Character vector. Restrict to these IDs. Default `NULL` = all.

- metrics:

  Character vector. Which metrics to report. Default
  `c("event_rate", "compliance_index")`.

## Value

A tibble with one row per resource configuration and columns `resource`,
`n_scenarios`, `n_reps`, and for each metric the median and 2.5%/97.5%
quantile.

## Examples

``` r
sim <- load_example_data()
resource_comparison(sim)
#> # A tibble: 3 × 9
#>   resource  n_scenarios n_reps event_rate_median event_rate_q025 event_rate_q975
#>   <chr>           <int>  <int>             <dbl>           <dbl>           <dbl>
#> 1 mixed               2    100             0.258           0.170           0.346
#> 2 none                1     50             0.341           0.266           0.414
#> 3 observat…           1     50             0.272           0.219           0.374
#> # ℹ 3 more variables: compliance_index_median <dbl>,
#> #   compliance_index_q025 <dbl>, compliance_index_q975 <dbl>
```
