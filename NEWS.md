# dynasimR 0.2.0

## Plots and reproducibility

* `plot_radar()` now joins the metrics of a scenario with straight lines on
  evenly spaced spokes. Before, the outline was bent into spirals and the
  metric names were clipped. Metric names are written outside the rim, ring
  values replace the overlapping radial axis, and the new argument `rescale`
  (default `FALSE`) puts metrics with different units on a common 0-1 axis.
* `plot_scenario_heatmap()` and the tile variant of `plot_sdi_map()` choose a
  light or dark label colour per tile; values on dark tiles and region names
  on near-white tiles were unreadable.
* `plot_sdi_map()` uses a red-blue instead of a red-green diverging scale, so
  under- and oversupply stay distinguishable with colour-vision deficiency,
  and reports a missing `region` or `sdi_median` column by name.
* `plot_al_tradeoff()` draws the AL labels above the optimum ring in a
  neutral colour, keeps the threshold label inside the panel, and says so
  when no autonomy level meets the threshold instead of printing a missing
  optimum.
* `plot_km()` and the policy narrative print p-values with their relation
  ("p = 0.005", "p < 0.001"). With one stratifying variable the legend and
  the risk table show the levels only, with the variable as legend title.
* `plot_cost_effectiveness()` places scenario labels above their points and
  inside the panel; it, `plot_map(color_by = "status")` and `plot_timeline()`
  use the package palette and titled legends. `plot_timeline()` explains its
  line and band in the caption.
* `policy_effect()`, `al_efficiency()`, `compute_compliance_index()`,
  `compute_wait_gap_index()` and `group_effect()` gain a `seed` argument
  (default `NULL`, the previous behaviour). A supplied seed makes the
  bootstrap intervals reproducible and leaves the caller's random-number
  state unchanged. The vignettes and examples now set it.
* `print()` for `policy_effect()` results wraps the narrative to the console
  width instead of printing one long line.
* Dashboard: static plots are rendered at 96 pixels per inch, so their text
  matches the size of the surrounding interface; effect-size, test and
  trade-off tables show four significant digits (sorting and export keep full
  precision); the autonomy tab names the scenarios of the default sweep that a
  dataset lacks, and its legend no longer overlaps the axis title. Its
  trade-off plot keeps the shaded compliant band and the threshold label,
  which the conversion to an interactive plot used to drop.
* The examples of `al_efficiency()` and `plot_al_tradeoff()` map the two
  autonomy levels of the bundled data instead of the full default sweep, which
  produced a single-point plot.
* `plot_al_tradeoff()` labels autonomy levels below the compliance threshold
  underneath their point, so the label no longer sits on the threshold line.
  `print()` for `al_efficiency()` results names the mapped scenarios that are
  missing from the data.
* `plot_policy()` titles its group axis and states in a caption that points
  are differences of medians and whiskers percentile bootstrap intervals at
  the chosen level. `plot_progress_curves()` explains its bars, whiskers,
  lines and bands in a caption and titles its legend.
* `plot_map()` titles its legend ("Group" or "Status"), and
  `plot_scenario_heatmap()` and `plot_sdi_map()` draw a wider colour bar so
  that their break labels no longer run together. The innermost ring of
  `plot_radar()` is no longer labelled, where the outlines covered it.
* The vignette figures carry alternative text.

## CRAN preparation

* Every exported function now has a runnable example. Examples write only to
  temporary files, and the dashboard example runs only in interactive
  sessions.
* Expand the `Description` field, declare the maintainer ORCID and rewrite
  `cran-comments.md`.

## Changes since 0.1.0 (prepared as 0.1.1, never released)

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
