#' 2D entity map snapshot
#'
#' Scatter plot of entity positions (requires `x` and `y` columns in
#' the entity table) coloured by group or status.
#'
#' @param data A `dynasimR_data` object or entity tibble with `x`,
#'   `y` columns.
#' @param color_by Character. `"group"` or `"status"`.
#'   Default `"group"`.
#' @param scenarios Character vector. Scenario IDs to include.
#'   Default `NULL` = all.
#' @return A ggplot2 object.
#' @examples
#' sim <- load_example_data()
#' plot_map(sim, scenarios = "A-S00")
#' @export
plot_map <- function(data,
                     color_by  = c("group", "status"),
                     scenarios = NULL) {

  color_by <- match.arg(color_by)
  d <- if (inherits(data, "dynasimR_data")) data$entities else data
  if (!all(c("x", "y") %in% names(d)))
    cli::cli_abort("Entity table needs 'x' and 'y' columns.")
  if (!is.null(scenarios))
    d <- dplyr::filter(d, .data$scenario %in% scenarios)

  p <- ggplot2::ggplot(
    d,
    ggplot2::aes(x = .data$x, y = .data$y,
                 color = .data[[color_by]])
  ) +
    ggplot2::geom_point(alpha = 0.6, size = 1.2) +
    ggplot2::coord_fixed() +
    ggplot2::labs(x = "X", y = "Y", color = NULL) +
    theme_dynasimR()

  if (color_by == "group")
    p <- p + scale_color_group_dynasimR()
  p
}
