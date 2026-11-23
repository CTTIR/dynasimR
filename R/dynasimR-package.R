#' dynasimR: Dynamic Agent-Node Simulation Analysis
#'
#' A domain-neutral analysis and visualisation layer for
#' discrete-event, agent-based and node-actor simulation outputs.
#' The package is schema-harmonised so that two interchangeable
#' output profiles (Profile A and Profile B) can be analysed with a
#' single API.
#'
#' @section Key functions:
#' \describe{
#'   \item{Data I/O}{[read_simulation()], [load_example_data()],
#'     [validate_dynasimR_data()]}
#'   \item{Time-to-event}{[km_estimate()], [cox_model()]}
#'   \item{Policy}{[policy_effect()]}
#'   \item{Autonomy}{[al_efficiency()]}
#'   \item{Compliance}{[compute_compliance_index()]}
#'   \item{Entity flow}{[stage_throughput()], [detect_bottlenecks()]}
#'   \item{Resource}{[resource_comparison()]}
#'   \item{Sensitivity}{[morris_screening()], [tornado_data()]}
#'   \item{Profile B helpers}{[progress_trajectory()],
#'     [compute_wait_gap_index()], [group_effect()],
#'     [spatial_supply_demand()], [compute_completion_analysis()]}
#'   \item{Plots}{[plot_km()], [plot_forest()], [plot_al_tradeoff()],
#'     [plot_scenario_heatmap()], [plot_policy()], [plot_timeline()],
#'     [plot_map()], [plot_progress_curves()], [plot_sdi_map()],
#'     [plot_cost_effectiveness()]}
#'   \item{Export}{[export_figure()], [export_latex_table()],
#'     [fill_placeholders()]}
#'   \item{Shiny}{[launch_app()], [check_app_dependencies()]}
#' }
#'
#' @keywords internal
#' @name dynasimR-package
#' @aliases dynasimR
#' @importFrom rlang .data
"_PACKAGE"

## --- Silence R CMD check notes about NSE bare names ---------------------
utils::globalVariables(c(
  # scenario_meta columns
  "id", "label", "rq", "policy", "resource", "al", "profile",
  # summary/entities columns
  "scenario", "replication", "profile_type", "event_rate",
  "compliance_index", "group", "severity", "severity_category",
  "time_to_stage2", "reached_stage2", "event_time", "event",
  "time_to_first_service", "received_service", "wait_days_to_min",
  "progress_gain", "progress_start", "progress_end",
  "wait_days", "region", "cohort",
  # tidy / survfit fields
  "time", "estimate", "conf.low", "conf.high", "strata", "term",
  "HR", "CI_low", "CI_high", "p.value",
  "event_median", "event_ci_lo", "event_ci_hi",
  "event_reduction_pct", "compliance", "above_threshold",
  "al_ratio", "n_total", "n_in_window", "ci",
  "compliance_critical", "window_min",
  # plot-internal vars
  "n_reps",
  # group_effect vars
  "cost", "completion_rate"
))
