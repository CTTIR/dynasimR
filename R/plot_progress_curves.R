#' Progress-score trajectory plot (Profile B)
#'
#' Plots longitudinal progress-score trajectories from the output of
#' [progress_trajectory()] (with `longitudinal = TRUE`).
#'
#' @param progress_result A `dynasimR_progress` object.
#' @param show_ci Logical. Show the central 2.5--97.5 percentile range
#'   of observed progress scores. This is a descriptive range, not a
#'   confidence interval; the argument name is retained for compatibility.
#'   Default `TRUE`.
#' @return A ggplot2 object.
#' @export
plot_progress_curves <- function(progress_result, show_ci = TRUE) {
  if (!inherits(progress_result, "dynasimR_progress"))
    cli::cli_abort(
      "{.arg progress_result} must be a dynasimR_progress object."
    )

  long <- progress_result$longitudinal
  if (is.null(long) || nrow(long) == 0) {
    # fallback: plot summary as bar chart
    d <- progress_result$summary
    p <- ggplot2::ggplot(d,
        ggplot2::aes(x = .data$scenario,
                     y = .data$progress_gain_median)) +
        ggplot2::geom_col(fill = dynasimR_colors()$GROUP_A)
    if (show_ci)
      p <- p +
        ggplot2::geom_errorbar(
          ggplot2::aes(ymin = .data$progress_gain_q025,
                       ymax = .data$progress_gain_q975),
          width = 0.3, color = dynasimR_colors()$NEUTRAL
        )
    return(p +
        ggplot2::labs(x = "Scenario",
                      y = "Median progress gain") +
        theme_dynasimR()
    )
  }

  p <- ggplot2::ggplot(long,
    ggplot2::aes(x = .data$time_step, y = .data$progress_median,
                 color = .data$scenario, fill = .data$scenario)
  )
  if (show_ci &&
      all(c("progress_q025", "progress_q975") %in% names(long)))
    p <- p +
      ggplot2::geom_ribbon(
        ggplot2::aes(ymin = .data$progress_q025,
                     ymax = .data$progress_q975),
        alpha = 0.15, color = NA
      )
  p +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::scale_color_viridis_d(option = "D",
                                   begin = 0.1, end = 0.9) +
    ggplot2::scale_fill_viridis_d(option = "D",
                                  begin = 0.1, end = 0.9) +
    ggplot2::labs(x = "Time step", y = "Progress score") +
    theme_dynasimR()
}
