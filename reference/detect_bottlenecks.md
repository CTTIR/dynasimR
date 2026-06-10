# Bottleneck detection across processing stages

Identifies scenario-stage combinations where the median transit time
exceeds a percentile threshold relative to the grand distribution.

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
