# Bottleneck detection across processing stages

Identifies scenario-stage combinations where the median recorded time
exceeds a percentile threshold relative to the grand distribution. This
descriptive ranking does not establish a capacity bottleneck, especially
when input times are cumulative or censored.

## Usage

``` r
detect_bottlenecks(data, threshold = 0.75)
```

## Arguments

- data:

  A `dynasimR_data` object or throughput tibble from
  [`stage_throughput()`](https://cttir.github.io/dynasimR/reference/stage_throughput.md).

- threshold:

  Numeric. Quantile above which a stage is flagged as a bottleneck
  (0-1). Default `0.75` (top quartile).

## Value

A tibble with only the bottleneck rows.

## Examples

``` r
sim <- load_example_data()
detect_bottlenecks(stage_throughput(sim))
#> # A tibble: 1 × 8
#>   scenario stage      n median_time   q25   q75 completed_frac is_bottleneck
#>   <chr>    <chr>  <int>       <dbl> <dbl> <dbl>          <dbl> <lgl>        
#> 1 A-S00    Stage2  4000         153    77   258          0.735 TRUE         
```
