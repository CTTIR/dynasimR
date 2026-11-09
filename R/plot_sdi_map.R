#' Supply-Demand Index choropleth
#'
#' Visualises per-region SDI as a tiled map. If the data contain `x`
#' and `y` region centroid columns, tiles are placed at those
#' coordinates; otherwise the regions are displayed as a simple
#' bar-style strip.
#'
#' @param sdi A tibble returned by [spatial_supply_demand()] plus
#'   optional `x`, `y` region centroid columns.
#' @return A ggplot2 object.
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
#' plot_sdi_map(spatial_supply_demand(runs))
#' @export
plot_sdi_map <- function(sdi) {

  has_xy <- all(c("x", "y") %in% names(sdi))

  if (has_xy) {
    ggplot2::ggplot(sdi,
      ggplot2::aes(x = .data$x, y = .data$y,
                   fill = .data$sdi_median)
    ) +
      ggplot2::geom_tile(color = "white", linewidth = 0.3) +
      ggplot2::geom_text(
        ggplot2::aes(label = .data$region),
        size = 2.5, color = "white"
      ) +
      ggplot2::scale_fill_gradient2(
        low = dynasimR_colors()$GROUP_B,
        mid = "white",
        high = dynasimR_colors()$POSITIVE,
        midpoint = 1
      ) +
      ggplot2::coord_fixed() +
      ggplot2::labs(fill = "SDI") +
      theme_dynasimR()
  } else {
    ggplot2::ggplot(sdi,
      ggplot2::aes(x = stats::reorder(.data$region,
                                      .data$sdi_median),
                   y = .data$sdi_median,
                   fill = .data$sdi_median)
    ) +
      ggplot2::geom_col() +
      ggplot2::geom_hline(yintercept = 1, linetype = "dashed",
                          color = "gray40") +
      ggplot2::scale_fill_gradient2(
        low = dynasimR_colors()$GROUP_B,
        mid = "white",
        high = dynasimR_colors()$POSITIVE,
        midpoint = 1
      ) +
      ggplot2::coord_flip() +
      ggplot2::labs(x = NULL, y = "Supply/Demand",
                    fill = "SDI") +
      theme_dynasimR()
  }
}
