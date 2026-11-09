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
and `params$n_obs` is the analysed sample size. When the optional
package `nnet` is unavailable, only proportions are returned with a
warning.

## Examples

``` r
set.seed(1)
entities <- data.frame(
  scenario           = rep(c("B-S00", "B-S01"), each = 40),
  cohort             = rep(c("early", "late"), times = 40),
  progress_start     = stats::runif(80, 40, 60),
  progress_end       = stats::runif(80, 60, 90),
  wait_days          = stats::rexp(80, 1 / 10),
  severity           = stats::runif(80),
  completion_outcome = factor(sample(c("full", "partial", "none"), 80,
                                     replace = TRUE))
)
ca <- compute_completion_analysis(entities)
ca$proportions
#> # A tibble: 6 × 4
#>   scenario completion_outcome     n  prop
#>   <chr>    <fct>              <int> <dbl>
#> 1 B-S00    full                  15 0.375
#> 2 B-S00    none                  15 0.375
#> 3 B-S00    partial               10 0.25 
#> 4 B-S01    full                  17 0.425
#> 5 B-S01    none                  12 0.3  
#> 6 B-S01    partial               11 0.275
```
