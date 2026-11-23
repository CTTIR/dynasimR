# Radar chart of metrics across scenarios

Quick visual summary of several outcome metrics by scenario. Each metric
is one spoke; the median across replications is plotted on it and the
points of a scenario are joined by straight lines. With two metrics the
outline degenerates to a line, so three or more metrics give the most
readable chart.

## Usage

``` r
plot_radar(
  data,
  scenarios,
  metrics = c("event_rate", "compliance_index"),
  rescale = FALSE
)
```

## Arguments

- data:

  A `dynasimR_data` object or summary tibble.

- scenarios:

  Character vector. Scenario IDs to show.

- metrics:

  Character vector. Numeric columns to plot, in spoke order. At least
  two must be present in the data.

- rescale:

  Logical. If `TRUE`, each metric is rescaled to the range 0 to 1 across
  the displayed scenarios (a metric without variation is drawn at 0.5),
  so metrics on different scales share the radial axis. Default `FALSE`
  plots the medians as they are, which is only meaningful for metrics on
  a common scale.

## Value

A ggplot2 object.

## Examples

``` r
sim <- load_example_data()
plot_radar(sim, scenarios = c("A-S00", "A-S08"))

plot_radar(sim, scenarios = c("A-S00", "A-S01", "A-S08"),
           metrics = c("event_rate", "compliance_index",
                       "median_time_to_first_service",
                       "median_time_to_stage2"),
           rescale = TRUE)
```
