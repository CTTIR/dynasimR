#' Descriptive cost-outcome plane and net-benefit fractions
#'
#' Compares scenario medians with fixed reference medians. The optional
#' threshold curve reports the observed fraction of scenario runs with
#' positive incremental net benefit relative to those fixed medians.
#' It does not propagate reference uncertainty, pair runs across scenarios,
#' or estimate a cost-effectiveness acceptability probability.
#' Higher outcome values are treated as better. Cost and willingness-to-pay
#' units must be consistent with the outcome unit.
#'
#' @param data A `dynasimR_data` object or summary tibble. Every selected
#'   row, including the reference, must have finite observed cost and outcome
#'   values together; incomplete pairs are rejected rather than silently
#'   using different observations for cost and outcome.
#' @param reference Character. One scenario ID used as the comparator.
#' @param scenarios Character vector. Unique scenario IDs to evaluate.
#'   Every requested ID must occur in the input.
#' @param outcome_col Character. Outcome column.
#'   Default `"completion_rate"`.
#' @param cost_col Character. Cost column. Default `"cost"`.
#' @param wtp Nonempty numeric vector of finite nonnegative willingness-to-pay
#'   thresholds. Default `seq(0, 2e5, length.out = 40)`.
#' @param show_ceac Logical. Legacy argument: `TRUE` returns the observed
#'   positive-net-benefit fraction curve, not an inferential CEAC.
#'   Default `FALSE` returns the median cost-outcome plane.
#' @return A ggplot2 object. Plane data include `delta_effect`, `delta_cost`,
#'   `icer` (their ratio, `NA` when the effect difference is zero), and
#'   `n_observed`. Curve data retain the legacy `prob_ce` column name for
#'   the observed fraction with strictly positive net benefit; ties do not
#'   count as positive. These fractions are not uncertainty probabilities.
#' @examples
#' set.seed(1)
#' runs <- data.frame(
#'   scenario        = rep(c("B-S00", "B-S01"), each = 20),
#'   replication     = rep(1:20, 2),
#'   completion_rate = c(stats::runif(20, 0.5, 0.7), stats::runif(20, 0.6, 0.8)),
#'   cost            = c(stats::runif(20, 900, 1100), stats::runif(20, 1000, 1300)),
#'   region          = rep(c("North", "South", "East", "West"), 10),
#'   supply          = stats::runif(40, 80, 120),
#'   demand          = stats::runif(40, 80, 120)
#' )
#' plot_cost_effectiveness(runs, reference = "B-S00", scenarios = "B-S01")
#' @export
plot_cost_effectiveness <- function(data,
                                    reference,
                                    scenarios,
                                    outcome_col = "completion_rate",
                                    cost_col = "cost",
                                    wtp = seq(0, 2e5, length.out = 40),
                                    show_ceac = FALSE) {
  for (nm in c("reference", "outcome_col", "cost_col")) {
    value <- get(nm)
    if (!is.character(value) || length(value) != 1L || is.na(value) ||
        !nzchar(trimws(value)))
      cli::cli_abort("{.arg {nm}} must be one nonempty name.")
  }
  if (!is.character(scenarios) || length(scenarios) == 0L ||
      anyNA(scenarios) || any(!nzchar(trimws(scenarios))) ||
      anyDuplicated(scenarios))
    cli::cli_abort("{.arg scenarios} must contain unique, nonempty IDs.")
  if (!is.logical(show_ceac) || length(show_ceac) != 1L || is.na(show_ceac))
    cli::cli_abort("{.arg show_ceac} must be TRUE or FALSE.")
  if (!is.numeric(wtp) || length(wtp) == 0L || anyNA(wtp) ||
      any(!is.finite(wtp)) || any(wtp < 0))
    cli::cli_abort("{.arg wtp} must contain finite nonnegative thresholds.")
  wtp <- sort(unique(wtp))

  d <- if (inherits(data, "dynasimR_data")) data$summary else data
  .require_cols(d, c("scenario", outcome_col, cost_col), where = "summary")
  if (!reference %in% d$scenario)
    cli::cli_abort("Reference {.val {reference}} not in data.")
  absent <- setdiff(scenarios, d$scenario)
  if (length(absent))
    cli::cli_abort("Scenarios not in data: {.val {absent}}.")
  d <- d[d$scenario %in% c(reference, scenarios), , drop = FALSE]
  for (nm in c(outcome_col, cost_col)) {
    if (!is.numeric(d[[nm]]) || any(!is.finite(d[[nm]])))
      cli::cli_abort(
        "Selected rows need finite observed cost-outcome pairs; {.field {nm}} is invalid."
      )
  }
  ref <- d[d$scenario == reference, , drop = FALSE]
  ref_out_med <- stats::median(ref[[outcome_col]])
  ref_cost_med <- stats::median(ref[[cost_col]])
  points <- purrr::map_dfr(scenarios, function(sc) {
    rows <- d[d$scenario == sc, , drop = FALSE]
    delta_effect <- stats::median(rows[[outcome_col]]) - ref_out_med
    delta_cost <- stats::median(rows[[cost_col]]) - ref_cost_med
    icer <- if (delta_effect == 0) NA_real_ else delta_cost / delta_effect
    if (!all(is.finite(c(delta_effect, delta_cost))) ||
        (!is.na(icer) && !is.finite(icer)))
      cli::cli_abort("Incremental values exceed the numeric range for {.val {sc}}.")
    tibble::tibble(scenario = sc, delta_effect = delta_effect,
                  delta_cost = delta_cost, icer = icer,
                  n_observed = nrow(rows))
  })
  comparator <- paste("Compared with fixed reference medians:", reference)
  if (!show_ceac) {
    return(
      ggplot2::ggplot(points,
        ggplot2::aes(x = .data$delta_effect, y = .data$delta_cost,
                     color = .data$scenario, label = .data$scenario)) +
        ggplot2::geom_hline(yintercept = 0, color = "gray60") +
        ggplot2::geom_vline(xintercept = 0, color = "gray60") +
        ggplot2::geom_point(size = 4) +
        ggplot2::geom_text(nudge_y = 0.02 * max(abs(points$delta_cost))) +
        ggplot2::labs(
          x = glue::glue("Median outcome difference ({outcome_col})"),
          y = glue::glue("Median cost difference ({cost_col})"),
          title = "Scenario cost-outcome differences", subtitle = comparator
        ) +
        theme_dynasimR()
    )
  }

  wtp_curves <- purrr::map_dfr(scenarios, function(sc) {
    rows <- d[d$scenario == sc, , drop = FALSE]
    delta_effect <- rows[[outcome_col]] - ref_out_med
    delta_cost <- rows[[cost_col]] - ref_cost_med
    observed_fraction <- vapply(wtp, function(w) {
      inb <- w * delta_effect - delta_cost
      if (any(!is.finite(inb)))
        cli::cli_abort("Net benefit exceeds the numeric range for {.val {sc}}.")
      mean(inb > 0)
    }, numeric(1))
    tibble::tibble(scenario = sc, wtp = wtp, prob_ce = observed_fraction,
                  n_observed = nrow(rows))
  })
  p <- ggplot2::ggplot(wtp_curves,
    ggplot2::aes(x = .data$wtp, y = .data$prob_ce, color = .data$scenario))
  if (length(wtp) > 1L) p <- p + ggplot2::geom_line(linewidth = 0.8)
  else p <- p + ggplot2::geom_point(size = 2)
  p +
    ggplot2::scale_y_continuous(limits = c(0, 1)) +
    ggplot2::labs(
      x = "Willingness-to-pay per outcome unit",
      y = "Observed fraction with positive net benefit",
      title = "Observed incremental net benefit", subtitle = comparator,
      caption = "Reference uncertainty is not estimated; higher outcomes are treated as better."
    ) +
    theme_dynasimR()
}
