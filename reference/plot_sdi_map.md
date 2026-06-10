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
