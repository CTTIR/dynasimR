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

  A `dynasimR_data` object or entity tibble.

- endpoint:

  See
  [`km_estimate()`](https://cttir.github.io/dynasimR/reference/km_estimate.md).

- covariates:

  Character vector. Covariates entering the Cox model. Default
  `c("scenario","severity","group")`.

- reference_scenario:

  Character. Reference level for the `scenario` factor. Default
  `"A-S00"`. Use `"B-S00"` for Profile B.

## Value

An S3 object of class `dynasimR_cox` with slots `fit`, `tidy`,
`ph_test`, `forest_data` and `params`.
