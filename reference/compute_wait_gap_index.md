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
