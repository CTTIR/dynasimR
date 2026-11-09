# Radar chart of metrics across scenarios

Quick visual summary of several outcome metrics by scenario using a
radial (polar) coordinate system.

## Usage

``` r
plot_radar(data, scenarios, metrics = c("event_rate", "compliance_index"))
```

## Arguments

- data:

  A `dynasimR_data` object or summary tibble.

- scenarios:

  Character vector. Scenario IDs to show.

- metrics:

  Character vector. Numeric columns to plot.

## Value

A ggplot2 object.

## Examples

``` r
sim <- load_example_data()
plot_radar(sim, scenarios = c("A-S00", "A-S08"))
```
