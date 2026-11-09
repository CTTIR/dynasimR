# Between-group prioritisation effect (Profile B)

Compares two Profile B scenarios that differ only in inclusion rules for
which groups are prioritised, and returns completion rates, the supplied
cost metric and their differences (A minus B) with bootstrap CIs. Cost
is summarized as supplied, not divided by completion rates. Replications
are assumed independent and unpaired. Missing values are omitted; each
scenario needs at least one observed completion rate. Intervals are
unavailable with fewer than two observations per group.

## Usage

``` r
group_effect(
  data,
  group_a_scenario,
  group_b_scenario,
  outcome_col = "completion_rate",
  cost_col = "cost",
  alpha = 0.05,
  n_bootstrap = 1000
)
```

## Arguments

- data:

  A `dynasimR_data` object or summary tibble.

- group_a_scenario:

  Character. Scenario ID for group A priority.

- group_b_scenario:

  Character. Scenario ID for group B priority.

- outcome_col:

  Character. Column name for the completion outcome. Default
  `"completion_rate"`.

- cost_col:

  Character. Column name for cost metric. Default `"cost"`.

- alpha:

  Numeric. Significance level. Default `0.05`.

- n_bootstrap:

  Integer. Bootstrap replicates. Default `1000`; `0` omits confidence
  intervals.

## Value

An S3 object of class `dynasimR_group_effect` with slots `completion`,
`cost`, `delta_completion`, `delta_cost`, `params`.

## Examples

``` r
set.seed(1)
runs <- data.frame(
  scenario        = rep(c("B-S00", "B-S01"), each = 20),
  replication     = rep(1:20, 2),
  completion_rate = c(stats::runif(20, 0.5, 0.7), stats::runif(20, 0.6, 0.8)),
  cost            = c(stats::runif(20, 900, 1100), stats::runif(20, 1000, 1300)),
  region          = rep(c("North", "South", "East", "West"), 10),
  supply          = stats::runif(40, 80, 120),
  demand          = stats::runif(40, 80, 120)
)
ge <- group_effect(runs, group_a_scenario = "B-S01",
                   group_b_scenario = "B-S00", n_bootstrap = 200)
ge$delta_completion
#> # A tibble: 1 × 3
#>   delta_median  ci_lo ci_hi
#>          <dbl>  <dbl> <dbl>
#> 1       0.0691 0.0291 0.137
```
