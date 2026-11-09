# Compliance Index

Fraction of entities (irrespective of group) that receive service within
a defined time window. A value below `0.80` is treated as a critical
compliance violation.

## Usage

``` r
compute_compliance_index(
  entities,
  window_min = 60,
  window_unit = c("min", "hours", "days"),
  by_scenario = TRUE,
  by_group = TRUE,
  n_bootstrap = 1000
)
```

## Arguments

- entities:

  A `dynasimR_data` object, or an entity-level tibble/data.frame with a
  `time_to_first_service` column (Profile A) or `wait_days_to_min`
  column (Profile B).

- window_min:

  Numeric. Window size, expressed in the unit given by `window_unit`.
  Default `60`.

- window_unit:

  Character. One of `"min"`, `"hours"`, `"days"`. Values are internally
  normalised to minutes.

- by_scenario:

  Logical. Compute per scenario. Default `TRUE`.

- by_group:

  Logical. Stratify by `group` if the column is present. Default `TRUE`.

- n_bootstrap:

  Integer. Bootstrap replicates for CIs. Default `1000`; `0` omits
  intervals.

## Value

A tibble with columns `scenario` (if stratified), `group` (if
stratified), `ci`, `ci_ci_lo`, `ci_ci_hi`, `n_total`, `n_in_window`,
`compliance_critical`, `window_min`.

## Details

When `received_service` is supplied, only a confirmed service (1) counts
in the numerator. Missing times or service indicators are not confirmed
timely service and remain in the denominator. Without an indicator, a
nonmissing time is assumed to represent received service. For Profile B
wait times, see
[`compute_wait_gap_index()`](https://cttir.github.io/dynasimR/reference/compute_wait_gap_index.md).
Bootstrap intervals treat entities as independent observations.

## Examples

``` r
sim <- load_example_data()
ci  <- compute_compliance_index(sim)
```
