# Scenario comparison heatmap

Heatmap of metric values (median across replications) for each
scenario-metric combination. Useful as an at-a-glance summary across all
scenarios.

## Usage

``` r
plot_scenario_heatmap(
  data,
  scenarios = NULL,
  metrics = c("event_rate", "compliance_index")
)
```

## Arguments

- data:

  A `dynasimR_data` object or summary tibble.

- scenarios:

  Character vector. Scenario IDs to show. Default `NULL` = all.

- metrics:

  Character vector. Numeric outcome columns. Default
  `c("event_rate", "compliance_index")`.

## Value

A ggplot2 object.
