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

  if (!is.data.frame(sdi))
    cli::cli_abort("{.arg sdi} must be a data frame from spatial_supply_demand().")
  .require_cols(sdi, c("region", "sdi_median"), where = "sdi")
  has_xy <- all(c("x", "y") %in% names(sdi))
  # Diverging red-blue scale around SDI = 1 (supply equals demand); unlike
  # red-green it stays distinguishable with colour-vision deficiency.
  fill_scale <- ggplot2::scale_fill_gradient2(
    low = dynasimR_colors()$GROUP_B,
    mid = "#F7F7F7",
    high = dynasimR_colors()$GROUP_A,
    midpoint = 1
  )

  if (has_xy) {
    # Tiles far from the midpoint are dark, tiles near it almost white:
    # choose the label colour accordingly.
    distance <- abs(sdi$sdi_median - 1)
    furthest <- suppressWarnings(max(distance, na.rm = TRUE))
    dark_tile <- is.finite(distance) & is.finite(furthest) & furthest > 0 &
      distance / furthest > 0.5
    ggplot2::ggplot(sdi,
      ggplot2::aes(x = .data$x, y = .data$y,
                   fill = .data$sdi_median)
    ) +
      ggplot2::geom_tile(color = "white", linewidth = 0.3) +
      ggplot2::geom_text(
        data = sdi[!dark_tile, , drop = FALSE],
        ggplot2::aes(label = .data$region),
        size = 3, color = "#1A1A1A"
      ) +
      ggplot2::geom_text(
        data = sdi[dark_tile, , drop = FALSE],
        ggplot2::aes(label = .data$region),
        size = 3, color = "white"
      ) +
      fill_scale +
      ggplot2::coord_fixed() +
      ggplot2::labs(x = "X", y = "Y", fill = "SDI (median)") +
      theme_dynasimR() +
      ggplot2::theme(legend.key.width = ggplot2::unit(2.5, "lines"))
  } else {
    ggplot2::ggplot(sdi,
      ggplot2::aes(x = stats::reorder(.data$region,
                                      .data$sdi_median),
                   y = .data$sdi_median,
                   fill = .data$sdi_median)
    ) +
      ggplot2::geom_col(color = "gray70", linewidth = 0.2) +
      ggplot2::geom_hline(yintercept = 1, linetype = "dashed",
                          color = "gray40") +
      fill_scale +
      ggplot2::coord_flip() +
      ggplot2::labs(x = NULL, y = "Supply-Demand Index (median)",
                    fill = "SDI (median)",
                    caption = "Dashed line: supply equals demand (SDI = 1).") +
      theme_dynasimR() +
      ggplot2::theme(legend.key.width = ggplot2::unit(2.5, "lines"))
  }
}
