# Stage throughput analysis

Computes median and interquartile range of recorded times for each
processing stage along the entity flow. If a `reached_stageN` column is
present in the entity data, computes the fraction of entities completing
each stage among nonmissing completion indicators. Time summaries use
all recorded nonmissing values, including values for unreached entities
if supplied; they are descriptive quantiles, not censoring-adjusted
estimates. A `time_to_stageN` column may contain cumulative elapsed time
rather than time spent in that stage.

## Usage

``` r
stage_throughput(data, stages = c("Stage1", "Stage2", "Stage3", "Stage4"))
```

## Arguments

- data:

  A `dynasimR_data` object or entity tibble.

- stages:

  Character vector. Stage labels in ordering. Default
  `c("Stage1", "Stage2", "Stage3", "Stage4")`.

## Value

A tibble with columns `scenario`, `stage`, `n`, `median_time`, `q25`,
`q75`, `completed_frac`.

## Examples

``` r
sim <- load_example_data()
stage_throughput(sim)
#> # A tibble: 4 × 7
#>   scenario stage      n median_time   q25   q75 completed_frac
#>   <chr>    <chr>  <int>       <dbl> <dbl> <dbl>          <dbl>
#> 1 A-S00    Stage2  4000         153    77  258           0.735
#> 2 A-S01    Stage2  4000         145    74  253           0.746
#> 3 A-S07    Stage2  4000         151    80  259           0.744
#> 4 A-S08    Stage2  4000         151    77  259.          0.782
```
