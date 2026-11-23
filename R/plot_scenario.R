#' Scenario comparison heatmap
#'
#' Heatmap of metric values (median across replications) for each
#' scenario-metric combination. Useful as an at-a-glance summary
#' across all scenarios.
#'
#' @param data A `dynasimR_data` object or summary tibble.
#' @param scenarios Character vector. Scenario IDs to show. Default
#'   `NULL` = all.
#' @param metrics Character vector. Numeric outcome columns.
#'   Default `c("event_rate", "compliance_index")`.
#' @return A ggplot2 object.
#' @examples
#' sim <- load_example_data()
#' plot_scenario_heatmap(sim)
#' @export
plot_scenario_heatmap <- function(data,
                                  scenarios = NULL,
                                  metrics   = c(
                                    "event_rate",
                                    "compliance_index"
                                  )) {

  d <- if (inherits(data, "dynasimR_data")) data$summary else data
  if (!is.null(scenarios))
    d <- dplyr::filter(d, .data$scenario %in% scenarios)
  metrics <- intersect(metrics, names(d))
  if (length(metrics) == 0)
    cli::cli_abort("None of the requested metrics are in summary.")

  long <- d |>
    dplyr::group_by(.data$scenario) |>
    dplyr::summarise(
      dplyr::across(dplyr::all_of(metrics),
                    ~ stats::median(.x, na.rm = TRUE)),
      .groups = "drop"
    ) |>
    tidyr::pivot_longer(cols = dplyr::all_of(metrics),
                        names_to = "metric",
                        values_to = "value")

  # The reversed palette is dark for high values: label those tiles in
  # white and the light ones in near-black so every value stays legible.
  long$label <- ifelse(is.na(long$value), "",
                       formatC(long$value, digits = 2, format = "f"))
  dark_tile <- .contrast_position(long$value) > 0.45

  ggplot2::ggplot(long,
    ggplot2::aes(x = .data$metric, y = .data$scenario,
                 fill = .data$value)
  ) +
    ggplot2::geom_tile(color = "white", linewidth = 0.3) +
    ggplot2::geom_text(
      data = long[!dark_tile, , drop = FALSE],
      ggplot2::aes(label = .data$label),
      size = 3, color = "#1A1A1A"
    ) +
    ggplot2::geom_text(
      data = long[dark_tile, , drop = FALSE],
      ggplot2::aes(label = .data$label),
      size = 3, color = "white"
    ) +
    ggplot2::scale_fill_viridis_c(option = "B", direction = -1) +
    ggplot2::labs(x = NULL, y = NULL, fill = "Median value") +
    theme_dynasimR() +
    # A wider colour bar keeps three-digit break labels apart.
    ggplot2::theme(legend.key.width = ggplot2::unit(2.5, "lines"))
}

# Position of each value within the observed range (0 = minimum,
# 1 = maximum); missing or constant input maps to 0. Used to choose a label
# colour that contrasts with a sequential fill.
#' @keywords internal
#' @noRd
.contrast_position <- function(x) {
  rng <- suppressWarnings(range(x[is.finite(x)]))
  if (!all(is.finite(rng)) || rng[2] == rng[1]) return(rep(0, length(x)))
  pos <- (x - rng[1]) / (rng[2] - rng[1])
  pos[!is.finite(pos)] <- 0
  pos
}
