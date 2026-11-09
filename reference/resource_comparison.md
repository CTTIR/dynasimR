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
if (FALSE) { # \dontrun{
sim <- load_example_data()
resource_comparison(sim)
} # }
```
