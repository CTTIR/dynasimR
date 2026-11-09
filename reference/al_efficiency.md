# Compute AL-Efficiency ratio (event reduction vs. compliance)

Quantifies the trade-off between event-rate reduction and the Compliance
Index across autonomy levels AL0-AL5. Returns the trade-off table, the
optimal AL level (highest event reduction still above the compliance
threshold) and observed compliance violations. Missing compliance is
unknown, cannot qualify an optimum, and is not labelled an observed
violation. `al_ratio` is a descriptive ratio
`event_reduction_pct / (1 - compliance + 0.001)` with a fixed
stabilizer; it is not a validated utility or a criterion used to choose
the optimum. `event_ci_lo` and `event_ci_hi` describe absolute event
rates. `event_reduction_ci_lo` and `event_reduction_ci_hi` are
percentile intervals for the reference-minus-scenario median difference
in percentage points, assuming independent replications between
scenarios. The reference compared with itself has zero difference and,
when an interval is requested with at least two observed rates, bounds
of zero.

## Usage

``` r
al_efficiency(
  data,
  al_scenarios = c(`0` = "A-S00", `1` = "A-S05", `2` = "A-S09", `3` = "A-S10", `4` =
    "A-S11", `5` = "A-S12"),
  compliance_threshold = 0.8,
  reference_al = 0,
  n_bootstrap = 1000
)
```

## Arguments

- data:

  A `dynasimR_data` object or summary tibble.

- al_scenarios:

  Named character vector. Mapping AL level (as a string) to scenario ID.
  Default assumes the Profile A scenarios (with the "A-" prefix).

- compliance_threshold:

  Numeric. Minimum Compliance Index for an AL level to be considered
  acceptable. Default `0.80`.

- reference_al:

  Integer. AL level used as reference for delta calculation. Default
  `0`.

- n_bootstrap:

  Integer. Bootstrap replicates for CIs. Default `1000`; `0` omits
  intervals.

## Value

An S3 object of class `dynasimR_al_analysis` with slots
`tradeoff_table`, `optimal_al`, `compliance_violations` and `params`.

## Examples

``` r
sim <- load_example_data()
al  <- al_efficiency(sim)
plot_al_tradeoff(al)
```
