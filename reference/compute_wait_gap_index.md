# Wait-Gap Index (Profile B)

Analogue of the Compliance Index for entity-flow profiles: fraction of
entities whose wait time from arrival to activation does not exceed a
threshold number of days (default 14). A value below `0.80` is flagged
as a critical wait-gap. Missing wait times remain in the denominator and
do not count as timely activation; negative or infinite waits are
rejected. Supply observed activation waits only: encode unactivated
entities with `NA`, not a censoring time. This index does not estimate a
censoring-adjusted probability.

## Usage

``` r
compute_wait_gap_index(
  data,
  window_days = 14,
  by_scenario = TRUE,
  by_cohort = TRUE,
  n_bootstrap = 1000
)
```

## Arguments

- data:

  A `dynasimR_data` object or entity tibble with a `wait_days` column
  (or `wait_days_to_min` in minutes).

- window_days:

  Numeric. Allowed wait time in days. Default `14`.

- by_scenario:

  Logical. Stratify by scenario. Default `TRUE`.

- by_cohort:

  Logical. Stratify by `cohort` (if present). Default `TRUE`.

- n_bootstrap:

  Integer. Bootstrap replicates for CIs. Default `1000`; `0` omits
  intervals. Bootstrap intervals treat entities as independent
  observations, without replication clustering.

## Value

A tibble with columns `scenario` (if stratified), `cohort` (if
stratified), `wgi`, `wgi_ci_lo`, `wgi_ci_hi`, `n_total`, `n_in_window`,
`wgi_critical`, `window_days`.

## Examples

``` r
set.seed(1)
entities <- data.frame(
  scenario           = rep(c("B-S00", "B-S01"), each = 40),
  cohort             = rep(c("early", "late"), times = 40),
  progress_start     = stats::runif(80, 40, 60),
  progress_end       = stats::runif(80, 60, 90),
  wait_days          = stats::rexp(80, 1 / 10),
  severity           = stats::runif(80),
  completion_outcome = factor(sample(c("full", "partial", "none"), 80,
                                     replace = TRUE))
)
compute_wait_gap_index(entities, n_bootstrap = 200)
#> # A tibble: 4 × 9
#>   scenario cohort n_total n_in_window   wgi wgi_ci_lo wgi_ci_hi wgi_critical
#>   <chr>    <chr>    <int>       <int> <dbl>     <dbl>     <dbl> <lgl>       
#> 1 B-S00    early       20          17  0.85      0.65     1     FALSE       
#> 2 B-S00    late        20          15  0.75      0.55     0.9   TRUE        
#> 3 B-S01    early       20          17  0.85      0.7      0.95  FALSE       
#> 4 B-S01    late        20          10  0.5       0.25     0.701 TRUE        
#> # ℹ 1 more variable: window_days <dbl>
```
