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
#' # The bundled example data hold two autonomy levels.
#' al <- al_efficiency(sim,
#'                     al_scenarios = c("0" = "A-S00", "1" = "A-S01"),
#'                     n_bootstrap  = 200)
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
    # Right-aligned at the panel edge, so the label is never clipped and
    # stays clear of the reference level at zero.
    ggplot2::annotate("text",
      x    = Inf,
      y    = thr,
      label = glue::glue("Compliance threshold ({thr})"),
      color = "#2E7D32", size = 3, hjust = 1.05, vjust = -0.6
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

  # Labels are drawn last, in a dark neutral colour and offset in text
  # heights, so they clear the optimum ring and stay legible on the band.
  if (label_points)
    p <- p +
      ggplot2::geom_text(
        ggplot2::aes(label = paste0("AL", .data$al)),
        vjust = -1.9, size = 3.5, fontface = "bold",
        color = "#333333", show.legend = FALSE
      )

  optimum <- if (is.na(opt)) "No autonomy level meets the threshold."
             else glue::glue("Optimum (circle): AL{opt}.")

  p +
    ggplot2::scale_color_viridis_d(
      name   = "Autonomy level",
      option = "plasma",
      begin  = 0.1, end = 0.9
    ) +
    ggplot2::scale_y_continuous(
      expand = ggplot2::expansion(mult = c(0.05, 0.12))
    ) +
    ggplot2::labs(
      x = glue::glue("Event reduction vs. AL{al_result$params$reference_al} [percentage points]"),
      y = "Compliance Index",
      title    = "Autonomy level trade-off",
      subtitle = "Event reduction vs. Compliance Index",
      caption  = glue::glue(
        "Green band: compliance >= {thr} (compliant). {optimum}"
      )
    ) +
    theme_dynasimR()
}

#' Radar chart of metrics across scenarios
#'
#' Quick visual summary of several outcome metrics by scenario. Each
#' metric is one spoke; the median across replications is plotted on it
#' and the points of a scenario are joined by straight lines. With two
#' metrics the outline degenerates to a line, so three or more metrics
#' give the most readable chart.
#'
#' @param data A `dynasimR_data` object or summary tibble.
#' @param scenarios Character vector. Scenario IDs to show.
#' @param metrics Character vector. Numeric columns to plot, in spoke
#'   order. At least two must be present in the data.
#' @param rescale Logical. If `TRUE`, each metric is rescaled to the
#'   range 0 to 1 across the displayed scenarios (a metric without
#'   variation is drawn at 0.5), so metrics on different scales share the
#'   radial axis. Default `FALSE` plots the medians as they are, which is
#'   only meaningful for metrics on a common scale.
#' @return A ggplot2 object.
#' @examples
#' sim <- load_example_data()
#' plot_radar(sim, scenarios = c("A-S00", "A-S08"))
#' plot_radar(sim, scenarios = c("A-S00", "A-S01", "A-S08"),
#'            metrics = c("event_rate", "compliance_index",
#'                        "median_time_to_first_service",
#'                        "median_time_to_stage2"),
#'            rescale = TRUE)
#' @export
plot_radar <- function(data,
                       scenarios,
                       metrics = c("event_rate",
                                   "compliance_index"),
                       rescale = FALSE) {

  if (!is.logical(rescale) || length(rescale) != 1L || is.na(rescale))
    cli::cli_abort("{.arg rescale} must be TRUE or FALSE.")
  d <- if (inherits(data, "dynasimR_data")) data$summary else data
  .require_cols(d, "scenario", where = "summary")
  d <- dplyr::filter(d, .data$scenario %in% scenarios)
  if (nrow(d) == 0)
    cli::cli_abort("None of the requested scenarios are in the data.")
  metrics <- intersect(metrics, names(d))
  metrics <- metrics[vapply(metrics, function(nm) is.numeric(d[[nm]]),
                            logical(1))]
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

  if (rescale) {
    long <- long |>
      dplyr::group_by(.data$metric) |>
      dplyr::mutate(value = .rescale_unit(.data$value)) |>
      dplyr::ungroup()
  }
  # Spokes sit at 1..n on a continuous angle axis of length n, which
  # spaces them evenly and puts the last metric at twelve o'clock.
  n_metrics <- length(metrics)
  long$spoke <- match(long$metric, metrics)
  long <- long[order(long$scenario, long$spoke), , drop = FALSE]
  upper <- max(long$value, 0, na.rm = TRUE)
  if (!is.finite(upper) || upper <= 0) upper <- 1
  # Rescaled minima are arbitrary zeros, so a hole in the middle keeps them
  # apart; raw medians keep an honest zero at the centre.
  lower <- if (rescale) -0.25 else min(long$value, 0, na.rm = TRUE)
  rim <- upper * 1.1
  rings <- pretty(c(max(lower, 0), upper), n = 4)
  rings <- rings[rings >= lower & rings <= upper]

  # Spoke labels are anchored at the rim and grow outwards, so they never
  # cover the data; ring values are written halfway between two spokes.
  angle <- 2 * pi * seq_len(n_metrics) / n_metrics
  side <- round(sin(angle), 6)
  height <- round(cos(angle), 6)
  spokes <- data.frame(
    spoke = seq_len(n_metrics), value = rim,
    label = ifelse(side > 0.1, paste0("  ", metrics),
                   ifelse(side < -0.1, paste0(metrics, "  "), metrics)),
    hjust = ifelse(side > 0.1, 0, ifelse(side < -0.1, 1, 0.5)),
    vjust = ifelse(height > 0.5, -0.6, ifelse(height < -0.5, 1.6, 0.5))
  )
  ring_labels <- data.frame(spoke = 0.5, value = rings,
                            label = format(rings, trim = TRUE))

  ggplot2::ggplot(long,
    ggplot2::aes(x = .data$spoke, y = .data$value)
  ) +
    ggplot2::geom_text(
      data = ring_labels, ggplot2::aes(label = .data$label),
      size = 2.8, color = "gray40"
    ) +
    ggplot2::geom_polygon(
      ggplot2::aes(color = .data$scenario, group = .data$scenario),
      fill = NA, linewidth = 0.8
    ) +
    ggplot2::geom_point(ggplot2::aes(color = .data$scenario), size = 2) +
    ggplot2::geom_text(
      data = spokes,
      ggplot2::aes(label = .data$label, hjust = .data$hjust,
                   vjust = .data$vjust),
      size = 3.2, color = "#333333"
    ) +
    ggplot2::scale_x_continuous(
      limits = c(0, n_metrics), breaks = seq_len(n_metrics),
      minor_breaks = NULL
    ) +
    ggplot2::scale_y_continuous(
      limits = c(lower, rim), breaks = rings, minor_breaks = NULL,
      expand = c(0, 0)
    ) +
    ggplot2::scale_color_manual(
      values = .safe_viridis(length(unique(long$scenario)))
    ) +
    .coord_radar() +
    ggplot2::labs(
      x = NULL, y = NULL, color = "Scenario",
      caption = if (rescale)
        "Median across replications, rescaled to 0-1 per metric."
      else "Median across replications."
    ) +
    theme_dynasimR() +
    ggplot2::theme(
      axis.text = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      plot.margin = ggplot2::margin(20, 20, 10, 20)
    )
}

#' @keywords internal
#' @noRd
.rescale_unit <- function(x) {
  rng <- range(x, na.rm = TRUE)
  if (!all(is.finite(rng))) return(rep(NA_real_, length(x)))
  if (rng[2] == rng[1]) return(ifelse(is.na(x), NA_real_, 0.5))
  (x - rng[1]) / (rng[2] - rng[1])
}

# Polar coordinates that join points by straight lines. coord_polar()
# interpolates every segment along the angle, which bends the outline of a
# radar chart into spirals; declaring the coordinate system linear keeps
# the segments straight. Labels are not clipped at the panel edge.
#' @keywords internal
#' @noRd
.coord_radar <- function() {
  ggplot2::ggproto(
    "CoordRadar", ggplot2::coord_polar(theta = "x", clip = "off"),
    is_linear = function() TRUE
  )
}
