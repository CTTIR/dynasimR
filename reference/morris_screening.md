# Standardized univariate sensitivity screening

Fits a separate linear association between each input and the outcome,
after standardizing paired complete observations. Despite its legacy
name, this function does not implement Morris elementary effects or a
variance decomposition. It can miss nonlinear effects and cannot
separate correlated inputs or establish causality. For a Morris design
use `sensitivity::morris()` on an appropriate simulation design.

## Usage

``` r
morris_screening(data, outcome = "event_rate", inputs)
```

## Arguments

- data:

  A `dynasimR_data` object or summary tibble.

- outcome:

  Character. Column name of the outcome to screen. Default
  `"event_rate"`.

- inputs:

  Character vector. Numeric simulation input columns. Each input needs
  at least three paired complete observations and variation in both the
  input and outcome; otherwise its statistics and rank are `NA`, with a
  reason in `status` and a warning.

## Value

A tibble with `input`, legacy `mu_star` (absolute standardized slope,
equal to absolute Pearson correlation), legacy `sigma` (standardized
regression residual SD), `r2`, `n_observed`, `status` and `rank`.
Missing pairs are omitted independently for each input.
