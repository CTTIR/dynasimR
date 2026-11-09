# 2D entity map snapshot

Scatter plot of entity positions (requires `x` and `y` columns in the
entity table) coloured by group or status.

## Usage

``` r
plot_map(data, color_by = c("group", "status"), scenarios = NULL)
```

## Arguments

- data:

  A `dynasimR_data` object or entity tibble with `x`, `y` columns.

- color_by:

  Character. `"group"` or `"status"`. Default `"group"`.

- scenarios:

  Character vector. Scenario IDs to include. Default `NULL` = all.

## Value

A ggplot2 object.
