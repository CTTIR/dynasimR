# Package index

## Data I/O

Load, validate and inspect simulation outputs.

- [`read_simulation()`](https://cttir.github.io/dynasimR/reference/read_simulation.md)
  : Load simulation outputs into the dynasimR standard format
- [`load_example_data()`](https://cttir.github.io/dynasimR/reference/load_example_data.md)
  : Load the package-bundled example dataset
- [`validate_dynasimR_data()`](https://cttir.github.io/dynasimR/reference/validate_dynasimR_data.md)
  : Validate a dynasimR_data object
- [`scenario_meta`](https://cttir.github.io/dynasimR/reference/scenario_meta.md)
  : Scenario metadata for Profile A and Profile B
- [`survival_params`](https://cttir.github.io/dynasimR/reference/survival_params.md)
  : Example Weibull event-time parameters by priority category

## Time-to-event analysis

Kaplan-Meier, Cox regression and associated plots.

- [`km_estimate()`](https://cttir.github.io/dynasimR/reference/km_estimate.md)
  : Kaplan-Meier estimator for simulation data
- [`cox_model()`](https://cttir.github.io/dynasimR/reference/cox_model.md)
  : Cox proportional-hazards model for simulation data
- [`plot_km()`](https://cttir.github.io/dynasimR/reference/plot_km.md) :
  Kaplan-Meier curves
- [`plot_forest()`](https://cttir.github.io/dynasimR/reference/plot_forest.md)
  : Forest plot of Cox hazard ratios

## Policy effects

Policy A vs. Policy B quantification.

- [`policy_effect()`](https://cttir.github.io/dynasimR/reference/policy_effect.md)
  : Quantify policy effect (policy A vs. policy B)
- [`plot_policy()`](https://cttir.github.io/dynasimR/reference/plot_policy.md)
  : Policy effect bar chart with CI whiskers

## Autonomy trade-off

AL0-AL5 event-vs-compliance analysis.

- [`al_efficiency()`](https://cttir.github.io/dynasimR/reference/al_efficiency.md)
  : Compute AL-Efficiency ratio (event reduction vs. compliance)
- [`plot_al_tradeoff()`](https://cttir.github.io/dynasimR/reference/plot_al_tradeoff.md)
  : Autonomy-level trade-off plot: event reduction vs. compliance
- [`plot_radar()`](https://cttir.github.io/dynasimR/reference/plot_radar.md)
  : Radar chart of metrics across scenarios

## Compliance / Entity flow

Compliance Index, throughput, bottlenecks.

- [`compute_compliance_index()`](https://cttir.github.io/dynasimR/reference/compute_compliance_index.md)
  : Compliance Index
- [`stage_throughput()`](https://cttir.github.io/dynasimR/reference/stage_throughput.md)
  : Stage throughput analysis
- [`detect_bottlenecks()`](https://cttir.github.io/dynasimR/reference/detect_bottlenecks.md)
  : Bottleneck detection across processing stages
- [`resource_comparison()`](https://cttir.github.io/dynasimR/reference/resource_comparison.md)
  : Compare outcomes across resource configurations

## Sensitivity analysis

- [`morris_screening()`](https://cttir.github.io/dynasimR/reference/morris_screening.md)
  : Morris-style sensitivity screening from simulation replicates
- [`tornado_data()`](https://cttir.github.io/dynasimR/reference/tornado_data.md)
  : Tornado-diagram data from one-at-a-time perturbation

## Profile B helpers

- [`progress_trajectory()`](https://cttir.github.io/dynasimR/reference/progress_trajectory.md)
  : Progress-score trajectory analysis (Profile B)
- [`compute_wait_gap_index()`](https://cttir.github.io/dynasimR/reference/compute_wait_gap_index.md)
  : Wait-Gap Index (Profile B)
- [`group_effect()`](https://cttir.github.io/dynasimR/reference/group_effect.md)
  : Between-group prioritisation effect (Profile B)
- [`compute_completion_analysis()`](https://cttir.github.io/dynasimR/reference/compute_completion_analysis.md)
  : Completion-outcome analysis (multinomial)
- [`spatial_supply_demand()`](https://cttir.github.io/dynasimR/reference/spatial_supply_demand.md)
  : Supply-Demand Index (SDI) per region
- [`plot_progress_curves()`](https://cttir.github.io/dynasimR/reference/plot_progress_curves.md)
  : Progress-score trajectory plot (Profile B)
- [`plot_sdi_map()`](https://cttir.github.io/dynasimR/reference/plot_sdi_map.md)
  : Supply-Demand Index choropleth
- [`plot_cost_effectiveness()`](https://cttir.github.io/dynasimR/reference/plot_cost_effectiveness.md)
  : Cost-effectiveness plane and CEAC curve

## Visualisation

- [`plot_map()`](https://cttir.github.io/dynasimR/reference/plot_map.md)
  : 2D entity map snapshot
- [`plot_scenario_heatmap()`](https://cttir.github.io/dynasimR/reference/plot_scenario_heatmap.md)
  : Scenario comparison heatmap
- [`plot_timeline()`](https://cttir.github.io/dynasimR/reference/plot_timeline.md)
  : Time-series plot of a simulation metric
- [`theme_dynasimR()`](https://cttir.github.io/dynasimR/reference/theme_dynasimR.md)
  : ggplot2 theme for dynasimR figures
- [`dynasimR_colors()`](https://cttir.github.io/dynasimR/reference/dynasimR_colors.md)
  : Colour palette for dynasimR plots
- [`scale_color_group_dynasimR()`](https://cttir.github.io/dynasimR/reference/scale_color_group_dynasimR.md)
  : Colour scale for entity group
- [`scale_fill_group_dynasimR()`](https://cttir.github.io/dynasimR/reference/scale_fill_group_dynasimR.md)
  : Fill scale for entity group
- [`scale_color_policy_dynasimR()`](https://cttir.github.io/dynasimR/reference/scale_color_policy_dynasimR.md)
  : Colour scale for policy

## Manuscript export

- [`export_figure()`](https://cttir.github.io/dynasimR/reference/export_figure.md)
  : Export a ggplot in publication-ready format

- [`export_latex_table()`](https://cttir.github.io/dynasimR/reference/export_latex_table.md)
  : Export a tibble as a publication-quality LaTeX table

- [`fill_placeholders()`](https://cttir.github.io/dynasimR/reference/fill_placeholders.md)
  :

  Fill `[XX_*]` placeholders in a LaTeX manuscript

## Shiny dashboard

- [`launch_app()`](https://cttir.github.io/dynasimR/reference/launch_app.md)
  : Launch the dynasimR Shiny dashboard
- [`check_app_dependencies()`](https://cttir.github.io/dynasimR/reference/check_app_dependencies.md)
  : Check availability of Shiny-app dependencies
