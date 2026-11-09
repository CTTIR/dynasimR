# Progress-score trajectory analysis (Profile B)

Summarises longitudinal progress-score trajectories by scenario and
optional grouping variables. By default, the summary pools entities
within each scenario; include `replication` in `group_by` for replicate
summaries. Quantile bounds describe the observed entity distribution,
not confidence intervals for the median. Also returns a longitudinal
tidy table suitable for
[`plot_progress_curves()`](https://cttir.github.io/dynasimR/reference/plot_progress_curves.md).

## Usage

``` r
progress_trajectory(data, group_by = c("scenario"), longitudinal = FALSE)
```

## Arguments

- data:

  A `dynasimR_data` object or entity/summary tibble that contains at
  least `progress_start` and `progress_end`.

- group_by:

  Character. Grouping columns. Default `c("scenario")`.

- longitudinal:

  Logical. If `TRUE`, returns the per-timepoint trajectories if a
  `progress_timeseries` slot is present in `data`.

## Value

An S3 object of class `dynasimR_progress` with slots `summary`,
`longitudinal` (if available) and `params`.

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
progress_trajectory(entities, group_by = c("scenario", "cohort"))
#> 
#> ── dynasimR_progress ───────────────────────────────────────────────────────────
#> # A tibble: 4 × 8
#>   scenario cohort     n progress_start_median progress_end_median
#>   <chr>    <chr>  <int>                 <dbl>               <dbl>
#> 1 B-S00    early     20                  52.8                76.3
#> 2 B-S00    late      20                  47.7                72.6
#> 3 B-S01    early     20                  49.6                75.6
#> 4 B-S01    late      20                  50.7                74.2
#> # ℹ 3 more variables: progress_gain_median <dbl>, progress_gain_q025 <dbl>,
#> #   progress_gain_q975 <dbl>
```
