#' Autonomy-level trade-off plot: event reduction vs. compliance
#'
#' @param al_result A `dynasimR_al_analysis` object.
#' @param label_points Logical. Annotate points with AL labels.
#'   Default `TRUE`.
#' @param highlight_optimal Logical. Circle the optimal AL.
#'   Default `TRUE`.
#' @return A ggplot2 object.
#' @examples
#' sim <- load_example_data()
#' al <- al_efficiency(sim)
#' plot_al_tradeoff(al)
#' @export
plot_al_tradeoff <- function(al_result,
                             label_points      = TRUE,
                             highlight_optimal = TRUE) {

  if (!inherits(al_result, "dynasimR_al_analysis"))
    cli::cli_abort(
      "{.arg al_result} must be a dynasimR_al_analysis object."
    )

  d   <- al_result$tradeoff_table
  thr <- al_result$compliance_threshold
  opt <- al_result$optimal_al

  p <- ggplot2::ggplot(
    d,
    ggplot2::aes(x = .data$event_reduction_pct,
                 y = .data$compliance,
                 color = factor(.data$al))
  ) +
    ggplot2::annotate("rect",
      xmin = -Inf, xmax = Inf,
      ymin = thr,  ymax = 1.0,
      fill = "#E8F5E9", alpha = 0.6
    ) +
    ggplot2::annotate("text",
      x    = max(d$event_reduction_pct, na.rm = TRUE) * 0.75,
      y    = thr + 0.01,
      label = glue::glue("Compliance threshold ({thr})"),
      color = "#2E7D32", size = 3, hjust = 0
    ) +
    ggplot2::geom_hline(yintercept = thr, linetype = "dashed",
                        color = "#2E7D32", linewidth = 0.5) +
    ggplot2::geom_errorbar(
      data = d[is.finite(d$event_reduction_ci_lo) &
                 is.finite(d$event_reduction_ci_hi), , drop = FALSE],
      ggplot2::aes(
        xmin = .data$event_reduction_ci_lo,
        xmax = .data$event_reduction_ci_hi
      ),
      orientation = "y", width = 0.005, alpha = 0.4
    ) +
    ggplot2::geom_point(size = 4)

  if (label_points)
    p <- p +
      ggplot2::geom_text(
        ggplot2::aes(label = paste0("AL", .data$al)),
        nudge_y = 0.015, size = 3.5, fontface = "bold"
      )

  if (highlight_optimal && !is.na(opt)) {
    opt_row <- dplyr::filter(d, .data$al == opt)
    if (nrow(opt_row) > 0)
      p <- p +
        ggplot2::geom_point(
          data   = opt_row,
          shape  = 1, size = 8,
          color  = dynasimR_colors()$POSITIVE,
          stroke = 1.5
        )
  }

  p +
    ggplot2::scale_color_viridis_d(
      name   = "Autonomy level",
      option = "plasma",
      begin  = 0.1, end = 0.9
    ) +
    ggplot2::labs(
      x = glue::glue("Event reduction vs. AL{al_result$params$reference_al} [percentage points]"),
      y = "Compliance Index",
      title    = "Autonomy level trade-off",
      subtitle = "Event reduction vs. Compliance Index",
      caption  = glue::glue(
        "Green band: compliance >= {thr} (compliant). ",
        "Optimum (circle): AL{opt}."
      )
    ) +
    theme_dynasimR()
}

#' Radar chart of metrics across scenarios
#'
#' Quick visual summary of several outcome metrics by scenario using
#' a radial (polar) coordinate system.
#'
#' @param data A `dynasimR_data` object or summary tibble.
#' @param scenarios Character vector. Scenario IDs to show.
#' @param metrics Character vector. Numeric columns to plot.
#' @return A ggplot2 object.
#' @examples
#' sim <- load_example_data()
#' plot_radar(sim, scenarios = c("A-S00", "A-S08"))
#' @export
plot_radar <- function(data,
                       scenarios,
                       metrics = c("event_rate",
                                   "compliance_index")) {

  d <- if (inherits(data, "dynasimR_data")) data$summary else data
  d <- dplyr::filter(d, .data$scenario %in% scenarios)
  metrics <- intersect(metrics, names(d))
  if (length(metrics) < 2)
    cli::cli_abort(
      "Need at least 2 numeric metrics present in the data."
    )

  long <- d |>
    dplyr::group_by(.data$scenario) |>
    dplyr::summarise(
      dplyr::across(dplyr::all_of(metrics),
                    ~ stats::median(.x, na.rm = TRUE)),
      .groups = "drop"
    ) |>
    tidyr::pivot_longer(cols = dplyr::all_of(metrics),
                        names_to = "metric", values_to = "value")

  ggplot2::ggplot(long,
    ggplot2::aes(x = .data$metric, y = .data$value,
                 color = .data$scenario, group = .data$scenario)
  ) +
    ggplot2::geom_polygon(fill = NA, linewidth = 0.8) +
    ggplot2::geom_point() +
    ggplot2::coord_polar() +
    theme_dynasimR()
}
