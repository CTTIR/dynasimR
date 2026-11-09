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

## Examples

``` r
sim <- load_example_data()
cx <- cox_model(sim, endpoint = "stage2")
cx
#> 
#> ── dynasimR_cox ────────────────────────────────────────────────────────────────
#> • Endpoint: "stage2"
#> • Covariates: "scenario", "severity", and "group"
#> • Reference: "A-S00"
#> • N: 16000
#> # A tibble: 6 × 8
#>   term             HR std.error statistic    p.value CI_low CI_high sig  
#>   <chr>         <dbl>     <dbl>     <dbl>      <dbl>  <dbl>   <dbl> <chr>
#> 1 scenarioA-S01 1.04     0.0260    1.53   0.125       0.989   1.10  ns   
#> 2 scenarioA-S07 0.999    0.0260   -0.0423 0.966       0.949   1.05  ns   
#> 3 scenarioA-S08 1.08     0.0257    2.97   0.00303     1.03    1.13  **   
#> 4 severity      0.840    0.0371   -4.70   0.00000262  0.781   0.903 ***  
#> 5 groupB        0.982    0.0206   -0.893  0.372       0.943   1.02  ns   
#> 6 groupC        1.01     0.0243    0.548  0.584       0.966   1.06  ns   
```
