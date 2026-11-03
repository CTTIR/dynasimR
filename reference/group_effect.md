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
