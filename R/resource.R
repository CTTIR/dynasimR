#' Compare outcomes across resource configurations
#'
#' Aggregates primary outcome metrics (event rate, Compliance Index
#' and - if present - median time-to-first-service) by the
#' `resource` column of the joined scenario metadata.
#'
#' @param data A `dynasimR_data` object or summary tibble.
#' @param scenarios Character vector. Restrict to these IDs.
#'   Default `NULL` = all.
#' @param metrics Character vector. Which metrics to report.
#'   Default `c("event_rate", "compliance_index")`.
#'
#' @return A tibble with one row per resource configuration and
#'   columns `resource`, `n_scenarios`, `n_reps`, and for each
#'   metric the median and 2.5%/97.5% quantile.
#' @export
#' @examples
#' sim <- load_example_data()
#' resource_comparison(sim)
resource_comparison <- function(data,
                                scenarios = NULL,
                                metrics   = c("event_rate",
                                              "compliance_index")) {

  d <- if (inherits(data, "dynasimR_data")) data$summary else data

  if (!"resource" %in% names(d))
    cli::cli_abort(
      "Summary table does not contain a 'resource' column. ",
      "Supply a resource column or a local scenario_metadata.csv."
    )

  if (!is.null(scenarios))
    d <- dplyr::filter(d, .data$scenario %in% scenarios)

  metrics <- intersect(metrics, names(d))
  if (length(metrics) == 0)
    cli::cli_abort("None of the requested metrics are in summary.")

  summ <- d |>
    dplyr::group_by(.data$resource) |>
    dplyr::summarise(
      n_scenarios = dplyr::n_distinct(.data$scenario),
      n_reps      = dplyr::n(),
      dplyr::across(
        dplyr::all_of(metrics),
        list(
          median = ~ stats::median(.x, na.rm = TRUE),
          q025   = ~ stats::quantile(.x, 0.025, na.rm = TRUE,
                                     names = FALSE),
          q975   = ~ stats::quantile(.x, 0.975, na.rm = TRUE,
                                     names = FALSE)
        ),
        .names = "{.col}_{.fn}"
      ),
      .groups = "drop"
    )
  summ
}
