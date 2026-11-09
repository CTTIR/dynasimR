# Quantify policy effect (policy A vs. policy B)

Computes the full suite of effect metrics comparing two scenarios that
differ only in the allocation policy. Returns deltas on the event rate
and the Compliance Index, Cohen's d, risk differences and an
auto-generated narrative suitable for pasting into a report. All
event-rate differences are signed policy A minus B. Cohen's d uses the
independent-sample, degrees-of-freedom-weighted pooled standard
deviation. Bootstrap intervals and Wilcoxon tests assume independent
simulation replications, not paired runs. `NNT_surrogate` is the
reciprocal absolute mean rate difference; its direction is supplied by
`Risk_Difference_event`. Missing replicate rates are omitted and
effective counts are recorded. Each scenario needs an observed rate;
intervals and standardized effects need at least two observations per
scenario. Subgroup rates use the binary `event` flag, or
`status == "TERMINATED"` only when the flag column is absent.

## Usage

``` r
policy_effect(
  data,
  policy_a_scenario,
  policy_b_scenario,
  alpha = 0.05,
  n_bootstrap = 1000
)
```

## Arguments

- data:

  A `dynasimR_data` object or summary tibble.

- policy_a_scenario:

  Character. Scenario ID for policy A.

- policy_b_scenario:

  Character. Scenario ID for policy B (the comparator).

- alpha:

  Numeric. Significance level. Default `0.05`.

- n_bootstrap:

  Integer. Bootstrap replicates for CIs. Default `1000`; `0` omits
  intervals.

## Value

An S3 object of class `dynasimR_policy` with slots `delta_event`,
`compliance_comparison`, `effect_sizes`, `wilcoxon_tests`, `narrative`,
and `params`.

## Details

No hardcoded defaults are used - you **must** supply both scenario IDs
explicitly, so that the same function works for Profile A (e.g.
`"A-S08"` vs. `"A-S07"`) and Profile B (e.g. `"B-S19"` vs. `"B-S00"`).

## Examples

``` r
if (FALSE) { # \dontrun{
sim <- load_example_data()
pol <- policy_effect(sim,
  policy_a_scenario = "A-S08", policy_b_scenario = "A-S07")
print(pol)
cat(pol$narrative)
} # }
```
