#' Policy effect bar chart with CI whiskers
#'
#' Plots the `delta_event` table from a `dynasimR_policy` object as
#' a horizontal bar chart with bootstrap CI whiskers.
#'
#' @param policy_result A `dynasimR_policy` object.
#' @return A ggplot2 object.
#' @examples
#' sim <- load_example_data()
#' pol <- policy_effect(sim, policy_a_scenario = "A-S08",
#'                      policy_b_scenario = "A-S07")
#' plot_policy(pol)
#' @export
plot_policy <- function(policy_result) {

  if (!inherits(policy_result, "dynasimR_policy"))
    cli::cli_abort(
      "{.arg policy_result} must be a dynasimR_policy object."
    )

  d <- policy_result$delta_event

  ggplot2::ggplot(d,
    ggplot2::aes(x = .data$median_pct_points,
                 y = stats::reorder(.data$group,
                                    .data$median_pct_points),
                 xmin = .data$ci_lo, xmax = .data$ci_hi)
  ) +
    ggplot2::geom_vline(xintercept = 0, linetype = "dashed",
                        color = "gray60", linewidth = 0.5) +
    ggplot2::geom_errorbar(data = d[is.finite(d$ci_lo) & is.finite(d$ci_hi), , drop = FALSE],
                            orientation = "y", width = 0.2, linewidth = 0.6,
                            color = dynasimR_colors()$NEUTRAL) +
    ggplot2::geom_point(size = 3,
                        color = dynasimR_colors()$GROUP_A) +
    ggplot2::labs(
      x = "Delta event rate (policy A - policy B) [pp]",
      y = NULL,
      title = "Policy effect",
      subtitle = glue::glue(
        "{policy_result$params$policy_a_scenario} vs. ",
        "{policy_result$params$policy_b_scenario}"
      )
    ) +
    theme_dynasimR()
}
