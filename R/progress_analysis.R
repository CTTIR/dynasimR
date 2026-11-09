#' Progress-score trajectory analysis (Profile B)
#'
#' Summarises longitudinal progress-score trajectories by scenario
#' and optional grouping variables. By default, the summary pools entities
#' within each scenario; include `replication` in `group_by` for replicate
#' summaries. Quantile bounds describe the observed entity distribution,
#' not confidence intervals for the median. Also returns a longitudinal
#' tidy table suitable for
#' [plot_progress_curves()].
#'
#' @param data A `dynasimR_data` object or entity/summary tibble
#'   that contains at least `progress_start` and `progress_end`.
#' @param group_by Character. Grouping columns. Default
#'   `c("scenario")`.
#' @param longitudinal Logical. If `TRUE`, returns the per-timepoint
#'   trajectories if a `progress_timeseries` slot is present in
#'   `data`.
#'
#' @return An S3 object of class `dynasimR_progress` with slots
#'   `summary`, `longitudinal` (if available) and `params`.
#' @examples
#' set.seed(1)
#' entities <- data.frame(
#'   scenario           = rep(c("B-S00", "B-S01"), each = 40),
#'   cohort             = rep(c("early", "late"), times = 40),
#'   progress_start     = stats::runif(80, 40, 60),
#'   progress_end       = stats::runif(80, 60, 90),
#'   wait_days          = stats::rexp(80, 1 / 10),
#'   severity           = stats::runif(80),
#'   completion_outcome = factor(sample(c("full", "partial", "none"), 80,
#'                                      replace = TRUE))
#' )
#' progress_trajectory(entities, group_by = c("scenario", "cohort"))
#' @export
progress_trajectory <- function(data,
                                group_by     = c("scenario"),
                                longitudinal = FALSE) {

  src <- if (inherits(data, "dynasimR_data")) data$entities else data
  if (nrow(src) == 0)
    cli::cli_abort("No entity rows in input.")

  req <- c("progress_start", "progress_end", group_by)
  .require_cols(src, req, where = "entities")
  for (nm in c("progress_start", "progress_end")) {
    value <- src[[nm]]
    if ((!is.numeric(value) && !(is.logical(value) && all(is.na(value)))) ||
        any(!is.na(value) & !is.finite(value)))
      cli::cli_abort("{.field {nm}} must contain finite numeric values or NA.")
  }

  summ <- src |>
    dplyr::group_by(dplyr::across(dplyr::all_of(group_by))) |>
    dplyr::summarise(
      n                      = dplyr::n(),
      progress_start_median  = stats::median(.data$progress_start,
                                             na.rm = TRUE),
      progress_end_median    = stats::median(.data$progress_end,
                                             na.rm = TRUE),
      progress_gain_median   = stats::median(
        .data$progress_end - .data$progress_start,
        na.rm = TRUE),
      progress_gain_q025     = stats::quantile(
        .data$progress_end - .data$progress_start,
        0.025, na.rm = TRUE, names = FALSE),
      progress_gain_q975     = stats::quantile(
        .data$progress_end - .data$progress_start,
        0.975, na.rm = TRUE, names = FALSE),
      .groups = "drop"
    )

  long <- NULL
  if (longitudinal && inherits(data, "dynasimR_data") &&
      "progress_timeseries" %in% names(data)) {
    long <- data$progress_timeseries
  } else if (longitudinal && "progress_timeseries" %in% names(src)) {
    long <- src$progress_timeseries
  } else if (longitudinal &&
             inherits(data, "dynasimR_data") &&
             "progress" %in% names(data$timeseries)) {
    .require_cols(data$timeseries, c(group_by, "time_step", "progress"),
                  where = "timeseries")
    value <- data$timeseries$progress
    if ((!is.numeric(value) && !(is.logical(value) && all(is.na(value)))) ||
        any(!is.na(value) & !is.finite(value)))
      cli::cli_abort("Time-series progress must contain finite numeric values or NA.")
    long <- data$timeseries |>
      dplyr::group_by(dplyr::across(dplyr::all_of(
        c(group_by, "time_step")))) |>
      dplyr::summarise(
        progress_median = stats::median(.data$progress,
                                        na.rm = TRUE),
        progress_q025   = stats::quantile(.data$progress, 0.025,
                                          na.rm = TRUE,
                                          names = FALSE),
        progress_q975   = stats::quantile(.data$progress, 0.975,
                                          na.rm = TRUE,
                                          names = FALSE),
        .groups         = "drop"
      )
  }

  structure(
    list(
      summary      = summ,
      longitudinal = long,
      params       = list(
        group_by     = group_by,
        longitudinal = longitudinal
      )
    ),
    class = c("dynasimR_progress", "list")
  )
}

#' @export
print.dynasimR_progress <- function(x, ...) {
  cli::cli_h1("dynasimR_progress")
  print(x$summary)
  invisible(x)
}
