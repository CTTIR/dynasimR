# Changelog

## dynasimR 0.1.1 (unreleased)

- Verify staged figure output before reporting success or replacing an
  existing file. Preserve prior exports on device failure, and enable
  the shared macOS XQuartz setup for SVG checks. Refuse failed SVG
  initialization before drawing on the caller’s device or opening a
  default output file.
- Validate each input file and preserve caller-supplied scenario
  metadata. Report zero-demand ratios as undefined, correct stage
  completion counts, and distinguish descriptive percentiles from
  confidence intervals.
- Correct signed policy narratives, bootstrap intervals and pooled
  effect sizes; reject invalid survival observations and missing model
  predictors.
- Preserve source manuscripts and existing outputs, treat identifiers as
  literal data, and validate requested placeholders before writing.
- Repair dashboard selection and profile handling, literal-text
  rendering, figure formats and LaTeX table compilation.
- Add actual survival risk tables, current ggplot2 interval geometry,
  portable developer checks and reproducible regression coverage.
- Clarify development/publication status; no new release has been
  published.

## dynasimR 0.1.0

- Standardize the named v5 package logo across README, documentation
  pages and available application headers, with matching light and dark
  artwork.

Initial release.

### Features

- Load and validate simulation outputs for two interchangeable profiles
  via
  [`read_simulation()`](https://cttir.github.io/dynasimR/reference/read_simulation.md)
  /
  [`load_example_data()`](https://cttir.github.io/dynasimR/reference/load_example_data.md).
- Time-to-event analysis with
  [`km_estimate()`](https://cttir.github.io/dynasimR/reference/km_estimate.md),
  [`cox_model()`](https://cttir.github.io/dynasimR/reference/cox_model.md),
  [`plot_km()`](https://cttir.github.io/dynasimR/reference/plot_km.md),
  [`plot_forest()`](https://cttir.github.io/dynasimR/reference/plot_forest.md).
- Policy-effect quantification via
  [`policy_effect()`](https://cttir.github.io/dynasimR/reference/policy_effect.md)
  with auto-generated LaTeX-ready narrative.
- Autonomy-level trade-off analysis via
  [`al_efficiency()`](https://cttir.github.io/dynasimR/reference/al_efficiency.md)
  and
  [`plot_al_tradeoff()`](https://cttir.github.io/dynasimR/reference/plot_al_tradeoff.md).
- Compliance Index via
  [`compute_compliance_index()`](https://cttir.github.io/dynasimR/reference/compute_compliance_index.md)
  with bootstrap confidence intervals.
- Profile B helpers:
  [`progress_trajectory()`](https://cttir.github.io/dynasimR/reference/progress_trajectory.md),
  [`compute_wait_gap_index()`](https://cttir.github.io/dynasimR/reference/compute_wait_gap_index.md),
  [`group_effect()`](https://cttir.github.io/dynasimR/reference/group_effect.md),
  [`spatial_supply_demand()`](https://cttir.github.io/dynasimR/reference/spatial_supply_demand.md),
  [`compute_completion_analysis()`](https://cttir.github.io/dynasimR/reference/compute_completion_analysis.md).
- Manuscript export:
  [`export_figure()`](https://cttir.github.io/dynasimR/reference/export_figure.md),
  [`export_latex_table()`](https://cttir.github.io/dynasimR/reference/export_latex_table.md),
  [`fill_placeholders()`](https://cttir.github.io/dynasimR/reference/fill_placeholders.md)
  (publisher-template compatible).
- Embedded Shiny dashboard via
  [`launch_app()`](https://cttir.github.io/dynasimR/reference/launch_app.md).
- Example data shipped for reproducible demos and tests.
