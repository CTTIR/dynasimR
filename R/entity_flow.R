#' Stage throughput analysis
#'
#' Computes median and interquartile range of recorded times for each
#' processing stage along the entity flow. If a `reached_stageN`
#' column is present in the entity data, computes the fraction of
#' entities completing each stage among nonmissing completion indicators.
#' Time summaries use all recorded nonmissing values, including values
#' for unreached entities if supplied; they are descriptive quantiles, not
#' censoring-adjusted estimates. A `time_to_stageN` column may contain
#' cumulative elapsed time rather than time spent in that stage.
#'
#' @param data A `dynasimR_data` object or entity tibble.
#' @param stages Character vector. Stage labels in ordering. Default
#'   `c("Stage1", "Stage2", "Stage3", "Stage4")`.
#'
#' @return A tibble with columns `scenario`, `stage`, `n`,
#'   `median_time`, `q25`, `q75`, `completed_frac`.
#' @export
stage_throughput <- function(data,
                             stages = c("Stage1", "Stage2",
                                        "Stage3", "Stage4")) {

  d <- if (inherits(data, "dynasimR_data")) data$entities else data

  .require_cols(d, "scenario", where = "entities")

  stage_time_col <- function(s) {
    candidates <- c(
      paste0("time_to_", tolower(s)),
      paste0("time_", tolower(s))
    )
    found <- intersect(candidates, names(d))
    if (length(found) == 0) NA_character_ else found[1]
  }

  out <- purrr::map_dfr(stages, function(s) {
    col <- stage_time_col(s)
    if (is.na(col)) return(NULL)
    .validate_elapsed_time(d[[col]], col)
    reached_col <- paste0("reached_", tolower(s))
    has_reached <- reached_col %in% names(d)
    if (has_reached) .validate_binary(d[[reached_col]], reached_col, allow_na = TRUE)
    d |>
      dplyr::group_by(.data$scenario) |>
      dplyr::summarise(
        stage       = s,
        n           = dplyr::n(),
        median_time = stats::median(.data[[col]], na.rm = TRUE),
        q25         = stats::quantile(.data[[col]], 0.25,
                                      na.rm = TRUE, names = FALSE),
        q75         = stats::quantile(.data[[col]], 0.75,
                                      na.rm = TRUE, names = FALSE),
        completed_frac = if (has_reached &&
                             any(!is.na(.data[[reached_col]])))
          mean(.data[[reached_col]], na.rm = TRUE)
        else NA_real_,
        .groups = "drop"
      )
  })
  out
}

#' Bottleneck detection across processing stages
#'
#' Identifies scenario-stage combinations where the median recorded
#' time exceeds a percentile threshold relative to the grand
#' distribution. This descriptive ranking does not establish a capacity
#' bottleneck, especially when input times are cumulative or censored.
#'
#' @param data A `dynasimR_data` object or throughput tibble from
#'   [stage_throughput()].
#' @param threshold Numeric. Quantile above which a stage is flagged
#'   as a bottleneck (0-1). Default `0.75` (top quartile).
#' @return A tibble with only the bottleneck rows.
#' @export
detect_bottlenecks <- function(data, threshold = 0.75) {

  if (inherits(data, "dynasimR_data"))
    tp <- stage_throughput(data)
  else tp <- data

  if (!"median_time" %in% names(tp))
    cli::cli_abort("Expected column 'median_time'.")

  cutoff <- stats::quantile(tp$median_time, probs = threshold,
                            na.rm = TRUE, names = FALSE)

  tp |>
    dplyr::mutate(is_bottleneck = .data$median_time > cutoff) |>
    dplyr::filter(.data$is_bottleneck)
}
