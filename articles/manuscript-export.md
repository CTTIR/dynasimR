# Manuscript export workflow

[![R-CMD-check](https://github.com/r-heller/dynasimR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/r-heller/dynasimR/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/r-heller/dynasimR/actions/workflows/pkgdown.yaml/badge.svg)](https://r-heller.github.io/dynasimR/)
[![CRAN
status](https://www.r-pkg.org/badges/version/dynasimR)](https://CRAN.R-project.org/package=dynasimR)
[![Codecov test
coverage](https://codecov.io/gh/r-heller/dynasimR/branch/main/graph/badge.svg)](https://app.codecov.io/gh/r-heller/dynasimR?branch=main)
[![CRAN
downloads](https://cranlogs.r-pkg.org/badges/dynasimR)](https://cran.r-project.org/package=dynasimR)
[![CRAN downloads
total](https://cranlogs.r-pkg.org/badges/grand-total/dynasimR)](https://cran.r-project.org/package=dynasimR)
[![License:
MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

This vignette shows how to get from raw simulation output to a
publication-quality document with automatically filled `[XX_*]`
placeholders.

## 1. LaTeX tables

``` r

library(dynasimR)
sim <- load_example_data()
pol <- policy_effect(sim,
  policy_a_scenario = "A-S08",
  policy_b_scenario = "A-S07")

export_latex_table(
  data     = pol$effect_sizes,
  filename = "table_policy.tex",
  caption  = "Policy effect sizes (Cohen's d and risk difference).",
  label    = "policy",
  note     = "n = 50 replications per scenario."
)
```

The generated `.tex` uses `\botrule` and escapes `<`/`>` in character
cells for compatibility with common publisher templates.

## 2. Figures at publication dimensions

``` r

km <- km_estimate(sim, endpoint = "stage2")
export_figure(
  plot      = plot_km(km),
  filename  = "figure_km.pdf",
  width_mm  = 174,          # single column
  height_mm = 110
)
```

## 3. Placeholder substitution in the .tex body

Given a source `manuscript.tex` with placeholders like
`[XX_POLICY_DELTA_EVENT]`, substitute them in one call:

``` r

reps <- fill_placeholders(
  sim_data          = sim,
  tex_file          = "manuscript.tex",
  output_file       = "manuscript_filled.tex",
  policy_a_scenario = "A-S08",
  policy_b_scenario = "A-S07",
  baseline_scenario = "A-S00"
)
reps          # named character vector of substitutions performed
```

## Complete placeholder list

| Placeholder | Source |
|----|----|
| `[XX_POLICY_DELTA_EVENT]` | [`policy_effect()`](https://cttir.github.io/dynasimR/reference/policy_effect.md) |
| `[XX_POLICY_DELTA_CI_LO]` | [`policy_effect()`](https://cttir.github.io/dynasimR/reference/policy_effect.md) |
| `[XX_POLICY_DELTA_CI_HI]` | [`policy_effect()`](https://cttir.github.io/dynasimR/reference/policy_effect.md) |
| `[XX_COMPLIANCE_A]` | [`compute_compliance_index()`](https://cttir.github.io/dynasimR/reference/compute_compliance_index.md) |
| `[XX_COMPLIANCE_B]` | [`compute_compliance_index()`](https://cttir.github.io/dynasimR/reference/compute_compliance_index.md) |
| `[XX_OPTIMAL_AL]` | [`al_efficiency()`](https://cttir.github.io/dynasimR/reference/al_efficiency.md) |
| `[XX_EVENT_BASELINE]` | median event rate at baseline scenario |
| `[XX_EVENT_BEST]` | min median event rate across all scenarios |
