# Descriptive cost-outcome plane and net-benefit fractions

Compares scenario medians with fixed reference medians. The optional
threshold curve reports the observed fraction of scenario runs with
positive incremental net benefit relative to those fixed medians. It
does not propagate reference uncertainty, pair runs across scenarios, or
estimate a cost-effectiveness acceptability probability. Higher outcome
values are treated as better. Cost and willingness-to-pay units must be
consistent with the outcome unit.

## Usage

``` r
plot_cost_effectiveness(
  data,
  reference,
  scenarios,
  outcome_col = "completion_rate",
  cost_col = "cost",
  wtp = seq(0, 2e+05, length.out = 40),
  show_ceac = FALSE
)
```

## Arguments

- data:

  A `dynasimR_data` object or summary tibble. Every selected row,
  including the reference, must have finite observed cost and outcome
  values together; incomplete pairs are rejected rather than silently
  using different observations for cost and outcome.

- reference:

  Character. One scenario ID used as the comparator.

- scenarios:

  Character vector. Unique scenario IDs to evaluate. Every requested ID
  must occur in the input.

- outcome_col:

  Character. Outcome column. Default `"completion_rate"`.

- cost_col:

  Character. Cost column. Default `"cost"`.

- wtp:

  Nonempty numeric vector of finite nonnegative willingness-to-pay
  thresholds. Default `seq(0, 2e5, length.out = 40)`.

- show_ceac:

  Logical. Legacy argument: `TRUE` returns the observed
  positive-net-benefit fraction curve, not an inferential CEAC. Default
  `FALSE` returns the median cost-outcome plane.

## Value

A ggplot2 object. Plane data include `delta_effect`, `delta_cost`,
`icer` (their ratio, `NA` when the effect difference is zero), and
`n_observed`. Curve data retain the legacy `prob_ce` column name for the
observed fraction with strictly positive net benefit; ties do not count
as positive. These fractions are not uncertainty probabilities.
