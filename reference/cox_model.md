# Cox proportional-hazards model for simulation data

Cox proportional-hazards model for simulation data

## Usage

``` r
cox_model(
  data,
  endpoint = c("stage2", "overall", "service"),
  covariates = c("scenario", "severity", "group"),
  reference_scenario = "A-S00"
)
```

## Arguments

- data:

  A `dynasimR_data` object or entity tibble. Endpoint times must be
  nonnegative finite observed event or censoring times; flags must be 0
  (censored) or 1 (event). Missing times, flags, strata, or model
  covariates are rejected rather than silently dropping entities.

- endpoint:

  See
  [`km_estimate()`](https://cttir.github.io/dynasimR/reference/km_estimate.md).

- covariates:

  Character vector. Covariates entering the Cox model. Default
  `c("scenario","severity","group")`; unavailable defaults are omitted
  with a warning for profile compatibility. Explicitly requested
  unavailable covariates are an error.

- reference_scenario:

  Character. Reference level for the `scenario` factor. Default
  `"A-S00"`. Use `"B-S00"` for Profile B.

## Value

An S3 object of class `dynasimR_cox` with slots `fit`, `tidy`,
`ph_test`, `forest_data` and `params`.
