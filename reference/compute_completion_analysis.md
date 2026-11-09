# Completion-outcome analysis (multinomial)

Fits a multinomial logistic regression of completion outcome
(categorical) on scenario + covariates. Returns the model, tidied
coefficients, and class-level proportions.

## Usage

``` r
compute_completion_analysis(data, covariates = c("scenario", "severity"))
```

## Arguments

- data:

  A `dynasimR_data` object or entity tibble with a `completion_outcome`
  column (factor) and `scenario`. At least two observed outcome classes
  are required. Missing outcomes or model inputs and rank-deficient
  predictor designs are rejected rather than silently changing the
  fitted sample or model.

- covariates:

  Character vector. Additional predictors. Default
  `c("scenario", "severity")`. Every requested column must exist;
  predictors are interpreted as column names, not R expressions.

## Value

An S3 object of class `dynasimR_completion` with slots `fit`, `tidy`,
`proportions`, `params`. Coefficient rows name the actual non-reference
outcome classes; `params$reference_outcome` is the first factor level
and `params$n_obs` is the analyzed sample size. When the optional
package `nnet` is unavailable, only proportions are returned with a
warning.
