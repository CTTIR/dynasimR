# Tornado-diagram data from one-at-a-time perturbation

Given a baseline scenario and perturbation scenarios, computes the
change in the outcome metric for each perturbation relative to the
baseline.

## Usage

``` r
tornado_data(data, baseline, perturbations, outcome = "event_rate")
```

## Arguments

- data:

  A `dynasimR_data` object or summary tibble.

- baseline:

  Character. Scenario ID of the baseline.

- perturbations:

  Character vector. Scenario IDs of one-at-a-time perturbations.

- outcome:

  Character. Column name of the outcome to measure. Default
  `"event_rate"`.

## Value

A tibble suitable for a tornado plot with columns `scenario`, `delta`,
`lo`, `hi`, sorted by absolute delta. `lo` and `hi` are the
perturbation's observed percentile range minus the fixed baseline
median, not a confidence interval for their difference.

## Examples

``` r
sim <- load_example_data()
tornado_data(sim, baseline = "A-S00",
             perturbations = c("A-S07", "A-S08"))
#> # A tibble: 2 × 4
#>   scenario   delta     lo      hi
#>   <chr>      <dbl>  <dbl>   <dbl>
#> 1 A-S08    -0.118  -0.180 -0.0369
#> 2 A-S07    -0.0447 -0.108  0.0108
```
