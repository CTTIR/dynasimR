# Policy effect bar chart with CI whiskers

Plots the `delta_event` table from a `dynasimR_policy` object as a
horizontal bar chart with bootstrap CI whiskers.

## Usage

``` r
plot_policy(policy_result)
```

## Arguments

- policy_result:

  A `dynasimR_policy` object.

## Value

A ggplot2 object.

## Examples

``` r
sim <- load_example_data()
pol <- policy_effect(sim, policy_a_scenario = "A-S08",
                     policy_b_scenario = "A-S07")
plot_policy(pol)
```
