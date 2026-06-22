# dynasimR: Dynamic Agent-Node Simulation Analysis

A domain-neutral analysis and visualisation layer for discrete-event,
agent-based and node-actor simulation outputs. The package is
schema-harmonised so that two interchangeable output profiles (Profile A
and Profile B) can be analysed with a single API.

## Key functions

- Data I/O:

  [`read_simulation()`](https://cttir.github.io/dynasimR/reference/read_simulation.md),
  [`load_example_data()`](https://cttir.github.io/dynasimR/reference/load_example_data.md),
  [`validate_dynasimR_data()`](https://cttir.github.io/dynasimR/reference/validate_dynasimR_data.md)

- Time-to-event:

  [`km_estimate()`](https://cttir.github.io/dynasimR/reference/km_estimate.md),
  [`cox_model()`](https://cttir.github.io/dynasimR/reference/cox_model.md)

- Policy:

  [`policy_effect()`](https://cttir.github.io/dynasimR/reference/policy_effect.md)

- Autonomy:

  [`al_efficiency()`](https://cttir.github.io/dynasimR/reference/al_efficiency.md)

- Compliance:

  [`compute_compliance_index()`](https://cttir.github.io/dynasimR/reference/compute_compliance_index.md)

- Entity flow:

  [`stage_throughput()`](https://cttir.github.io/dynasimR/reference/stage_throughput.md),
  [`detect_bottlenecks()`](https://cttir.github.io/dynasimR/reference/detect_bottlenecks.md)

- Resource:

  [`resource_comparison()`](https://cttir.github.io/dynasimR/reference/resource_comparison.md)

- Sensitivity:

  [`morris_screening()`](https://cttir.github.io/dynasimR/reference/morris_screening.md),
  [`tornado_data()`](https://cttir.github.io/dynasimR/reference/tornado_data.md)

- Profile B helpers:

  [`progress_trajectory()`](https://cttir.github.io/dynasimR/reference/progress_trajectory.md),
  [`compute_wait_gap_index()`](https://cttir.github.io/dynasimR/reference/compute_wait_gap_index.md),
  [`group_effect()`](https://cttir.github.io/dynasimR/reference/group_effect.md),
  [`spatial_supply_demand()`](https://cttir.github.io/dynasimR/reference/spatial_supply_demand.md),
  [`compute_completion_analysis()`](https://cttir.github.io/dynasimR/reference/compute_completion_analysis.md)

- Plots:

  [`plot_km()`](https://cttir.github.io/dynasimR/reference/plot_km.md),
  [`plot_forest()`](https://cttir.github.io/dynasimR/reference/plot_forest.md),
  [`plot_al_tradeoff()`](https://cttir.github.io/dynasimR/reference/plot_al_tradeoff.md),
  [`plot_scenario_heatmap()`](https://cttir.github.io/dynasimR/reference/plot_scenario_heatmap.md),
  [`plot_policy()`](https://cttir.github.io/dynasimR/reference/plot_policy.md),
  [`plot_timeline()`](https://cttir.github.io/dynasimR/reference/plot_timeline.md),
  [`plot_map()`](https://cttir.github.io/dynasimR/reference/plot_map.md),
  [`plot_progress_curves()`](https://cttir.github.io/dynasimR/reference/plot_progress_curves.md),
  [`plot_sdi_map()`](https://cttir.github.io/dynasimR/reference/plot_sdi_map.md),
  [`plot_cost_effectiveness()`](https://cttir.github.io/dynasimR/reference/plot_cost_effectiveness.md)

- Export:

  [`export_figure()`](https://cttir.github.io/dynasimR/reference/export_figure.md),
  [`export_latex_table()`](https://cttir.github.io/dynasimR/reference/export_latex_table.md),
  [`fill_placeholders()`](https://cttir.github.io/dynasimR/reference/fill_placeholders.md)

- Shiny:

  [`launch_app()`](https://cttir.github.io/dynasimR/reference/launch_app.md),
  [`check_app_dependencies()`](https://cttir.github.io/dynasimR/reference/check_app_dependencies.md)

## See also

Useful links:

- <https://github.com/cttir/dynasimR>

- <https://cttir.github.io/dynasimR/>

- Report bugs at <https://github.com/cttir/dynasimR/issues>

## Author

**Maintainer**: R. Heller <r-heller@example.org>

Authors:

- R. Heller <r-heller@example.org>
