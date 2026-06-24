# Policy effects: Policy A vs. Policy B

[![R-CMD-check](https://github.com/CTTIR/dynasimR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/CTTIR/dynasimR/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/CTTIR/dynasimR/actions/workflows/pkgdown.yaml/badge.svg)](https://cttir.github.io/dynasimR/)
[![CRAN
status](https://www.r-pkg.org/badges/version/dynasimR)](https://CRAN.R-project.org/package=dynasimR)
[![Codecov test
coverage](https://codecov.io/gh/CTTIR/dynasimR/branch/main/graph/badge.svg)](https://app.codecov.io/gh/CTTIR/dynasimR?branch=main)
[![CRAN
downloads](https://cranlogs.r-pkg.org/badges/dynasimR)](https://cran.r-project.org/package=dynasimR)
[![CRAN downloads
total](https://cranlogs.r-pkg.org/badges/grand-total/dynasimR)](https://cran.r-project.org/package=dynasimR)
[![License:
MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

``` r

library(dynasimR)
sim <- load_example_data()
```

## The core comparison

The two Profile A scenarios `A-S07` (policy B) and `A-S08` (policy A,
priority by severity) differ only in the allocation policy.

``` r

pol <- policy_effect(
  sim,
  policy_a_scenario = "A-S08",
  policy_b_scenario = "A-S07",
  n_bootstrap       = 500
)
print(pol)
#> 
#> ── dynasimR_policy ─────────────────────────────────────────────────────────────
#> • Policy A: "A-S08"
#> • Policy B: "A-S07"
#> • n (reps): 50
#> 
#> ── Delta event rate ──
#> 
#> # A tibble: 4 × 4
#>   group median_pct_points  ci_lo ci_hi
#>   <chr>             <dbl>  <dbl> <dbl>
#> 1 all               -7.37  -9.10 -5.53
#> 2 A                -10.6  -14.4  -7.00
#> 3 B                -11.3  -14.9  -7.65
#> 4 C                 -9.39 -16.1  -4.13
#> ── Narrative ──
#> Under policy A (scenario A-S08), an event-rate reduction of 7.4 percentage points (95\%-CI: -9.1 to -5.5) was observed versus policy B (scenario A-S07) (Wilcoxon test: W = 215, p < 0.001). The Compliance Index was higher under policy A (0.919 vs. 0.658).
```

## Delta event-rate visualisation

``` r

plot_policy(pol)
#> `height` was translated to `width`.
```

![](policy-effects_files/figure-html/unnamed-chunk-3-1.png)

## Auto-generated narrative

The `narrative` slot is a LaTeX-escaped string ready to drop into a
report:

``` r

cat(pol$narrative)
```

Under policy A (scenario A-S08), an event-rate reduction of 7.4
percentage points (95%-CI: -9.1 to -5.5) was observed versus policy B
(scenario A-S07) (Wilcoxon test: W = 215, p \< 0.001). The Compliance
Index was higher under policy A (0.919 vs. 0.658).

## Effect sizes

``` r

pol$effect_sizes
#> # A tibble: 3 × 2
#>   metric                  value
#>   <chr>                   <dbl>
#> 1 Cohen_d_event         -1.95  
#> 2 Risk_Difference_event -0.0685
#> 3 NNT_surrogate         14.6
```
