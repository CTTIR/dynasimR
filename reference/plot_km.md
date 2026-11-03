# Kaplan-Meier curves

Plots a `dynasimR_km` object.

## Usage

``` r
plot_km(
  km_result,
  show_ci = TRUE,
  show_risktable = FALSE,
  show_pval = TRUE,
  show_median = TRUE,
  color_by = "scenario",
  title = NULL,
  subtitle = NULL,
  xlab = "Time",
  ylab = "Survival probability",
  xlim = NULL,
  manuscript_width = 174,
  ...
)
```

## Arguments

- km_result:

  A `dynasimR_km` object.

- show_ci:

  Logical. Show CI ribbon. Default `TRUE`.

- show_risktable:

  Logical. Show numbers at risk immediately before each displayed time
  (requires patchwork). Default `FALSE`.

- show_pval:

  Logical. Annotate log-rank p-value. Default `TRUE`.

- show_median:

  Logical. Draw horizontal 50% reference line. Default `TRUE`.

- color_by:

  Character. Palette hint: `"policy"` uses policy colours for at most
  two strata; otherwise uses a discrete palette. Curves always retain
  the strata fitted by
  [`km_estimate()`](https://cttir.github.io/dynasimR/reference/km_estimate.md);
  this does not regroup them.

- title, subtitle, xlab, ylab:

  Character overrides.

- xlim:

  Numeric length-2. Restrict x range. Default `NULL`.

- manuscript_width:

  Numeric. Retained for compatibility; does not resize the plot. Set
  `width_mm` in
  [`export_figure()`](https://cttir.github.io/dynasimR/reference/export_figure.md)
  instead.

- ...:

  Unused.

## Value

A ggplot2 object, or a patchwork composition when
`show_risktable = TRUE`.
