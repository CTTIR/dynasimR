# Supply-Demand Index choropleth

Visualises per-region SDI as a tiled map. If the data contain `x` and
`y` region centroid columns, tiles are placed at those coordinates;
otherwise the regions are displayed as a simple bar-style strip.

## Usage

``` r
plot_sdi_map(sdi)
```

## Arguments

- sdi:

  A tibble returned by
  [`spatial_supply_demand()`](https://cttir.github.io/dynasimR/reference/spatial_supply_demand.md)
  plus optional `x`, `y` region centroid columns.

## Value

A ggplot2 object.

## Examples

``` r
set.seed(1)
runs <- data.frame(
  scenario        = rep(c("B-S00", "B-S01"), each = 20),
  replication     = rep(1:20, 2),
  completion_rate = c(stats::runif(20, 0.5, 0.7), stats::runif(20, 0.6, 0.8)),
  cost            = c(stats::runif(20, 900, 1100), stats::runif(20, 1000, 1300)),
  region          = rep(c("North", "South", "East", "West"), 10),
  supply          = stats::runif(40, 80, 120),
  demand          = stats::runif(40, 80, 120)
)
plot_sdi_map(spatial_supply_demand(runs))
```
