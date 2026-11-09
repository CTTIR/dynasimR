#' Time-series plot of a simulation metric
#'
#' Plots a metric column from the `timeseries` table over `time_step`,
#' stratified by scenario (and optionally another variable).
#'
#' @param data A `dynasimR_data` object or timeseries tibble.
#' @param metric Character. Name of the numeric column to plot.
#' @param scenarios Character vector. Scenario IDs. Default `NULL`.
#' @param group Character. Additional grouping variable, e.g.
#'   `"group"`. Default `NULL`.
#' @return A ggplot2 object.
#' @examples
#' sim <- load_example_data()
#' plot_timeline(sim, metric = "capacity_utilisation")
#' @export
plot_timeline <- function(data,
                          metric,
                          scenarios = NULL,
                          group     = NULL) {

  d <- if (inherits(data, "dynasimR_data")) data$timeseries else data
  if (nrow(d) == 0)
    cli::cli_abort("Timeseries table is empty.")
  if (!metric %in% names(d))
    cli::cli_abort("Metric {.val {metric}} not in timeseries.")
  if (!is.null(scenarios))
    d <- dplyr::filter(d, .data$scenario %in% scenarios)

  gvars <- c("scenario", "time_step")
  if (!is.null(group) && group %in% names(d))
    gvars <- c(gvars, group)

  agg <- d |>
    dplyr::group_by(dplyr::across(dplyr::all_of(gvars))) |>
    dplyr::summarise(
      med = stats::median(.data[[metric]], na.rm = TRUE),
      lo  = stats::quantile(.data[[metric]], 0.025,
                            na.rm = TRUE, names = FALSE),
      hi  = stats::quantile(.data[[metric]], 0.975,
                            na.rm = TRUE, names = FALSE),
      .groups = "drop"
    )

  p <- ggplot2::ggplot(agg,
    ggplot2::aes(x = .data$time_step, y = .data$med,
                 color = .data$scenario, fill = .data$scenario)
  ) +
    ggplot2::geom_ribbon(
      ggplot2::aes(ymin = .data$lo, ymax = .data$hi),
      alpha = 0.15, color = NA
    ) +
    ggplot2::geom_line(linewidth = 0.7) +
    ggplot2::scale_color_viridis_d(option = "D",
                                   begin = 0.1, end = 0.9) +
    ggplot2::scale_fill_viridis_d(option = "D",
                                  begin = 0.1, end = 0.9) +
    ggplot2::labs(x = "Time step", y = metric) +
    theme_dynasimR()

  if (!is.null(group) && group %in% names(d))
    p <- p + ggplot2::facet_wrap(group)
  p
}
