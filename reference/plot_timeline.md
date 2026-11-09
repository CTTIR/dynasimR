# Time-series plot of a simulation metric

Plots a metric column from the `timeseries` table over `time_step`,
stratified by scenario (and optionally another variable).

## Usage

``` r
plot_timeline(data, metric, scenarios = NULL, group = NULL)
```

## Arguments

- data:

  A `dynasimR_data` object or timeseries tibble.

- metric:

  Character. Name of the numeric column to plot.

- scenarios:

  Character vector. Scenario IDs. Default `NULL`.

- group:

  Character. Additional grouping variable, e.g. `"group"`. Default
  `NULL`.

## Value

A ggplot2 object.
