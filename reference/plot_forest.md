# Forest plot of Cox hazard ratios

Forest plot of Cox hazard ratios

## Usage

``` r
plot_forest(cox_result, reference_label = "No effect (HR = 1)", ...)
```

## Arguments

- cox_result:

  A `dynasimR_cox` object.

- reference_label:

  Character. Label for HR = 1 reference line. Default
  `"No effect (HR = 1)"`.

- ...:

  Unused.

## Value

A ggplot2 object.
