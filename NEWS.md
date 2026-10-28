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
