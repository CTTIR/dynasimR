# dynasimR 0.1.1 (unreleased)

* Verify staged figure output before reporting success or replacing an existing
  file. Preserve prior exports on device failure, and enable the shared macOS
  XQuartz setup for SVG checks. Refuse failed SVG initialization before drawing
  on the caller's device or opening a default output file.
* Validate each input file and preserve caller-supplied scenario metadata.
  Report zero-demand ratios as undefined, correct stage completion counts,
  and distinguish descriptive percentiles from confidence intervals.
* Correct signed policy narratives, bootstrap intervals and pooled effect
  sizes; reject invalid survival observations and missing model predictors.
* Preserve source manuscripts and existing outputs, treat identifiers as
  literal data, and validate requested placeholders before writing.
* Repair dashboard selection and profile handling, literal-text rendering,
  figure formats and LaTeX table compilation.
* Add actual survival risk tables, current ggplot2 interval geometry, portable
  developer checks and reproducible regression coverage.
* Clarify development/publication status; no new release has been published.

# dynasimR 0.1.0

* Standardize the named v5 package logo across README, documentation pages
  and available application headers, with matching light and dark artwork.


Initial release.

## Features

- Load and validate simulation outputs for two interchangeable
  profiles via `read_simulation()` / `load_example_data()`.
- Time-to-event analysis with `km_estimate()`, `cox_model()`,
  `plot_km()`, `plot_forest()`.
- Policy-effect quantification via `policy_effect()` with
  auto-generated LaTeX-ready narrative.
- Autonomy-level trade-off analysis via `al_efficiency()` and
  `plot_al_tradeoff()`.
- Compliance Index via `compute_compliance_index()` with bootstrap
  confidence intervals.
- Profile B helpers: `progress_trajectory()`,
  `compute_wait_gap_index()`, `group_effect()`,
  `spatial_supply_demand()`, `compute_completion_analysis()`.
- Manuscript export: `export_figure()`, `export_latex_table()`,
  `fill_placeholders()` (publisher-template compatible).
- Embedded Shiny dashboard via `launch_app()`.
- Example data shipped for reproducible demos and tests.
