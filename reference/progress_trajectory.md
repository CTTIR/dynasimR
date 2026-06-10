# Progress-score trajectory analysis (Profile B)

Summarises longitudinal progress-score trajectories by scenario and
(optionally) cohort. Returns both a per-replication summary (start, end,
gain) and a longitudinal tidy table suitable for
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
