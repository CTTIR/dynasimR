#' Compliance Index
#'
#' Fraction of entities (irrespective of group) that receive service
#' within a defined time window. A value below `0.80` is treated as
#' a critical compliance violation.
#'
#' When `received_service` is supplied, only a confirmed service (1)
#' counts in the numerator. Missing times or service indicators are not
#' confirmed timely service and remain in the denominator. Without an
#' indicator, a nonmissing time is assumed to represent received service.
#' For Profile B wait times, see [compute_wait_gap_index()].
#' Bootstrap intervals treat entities as independent observations.
#'
#' @param entities A `dynasimR_data` object, or an entity-level
#'   tibble/data.frame with a `time_to_first_service` column
#'   (Profile A) or `wait_days_to_min` column (Profile B).
#' @param window_min Numeric. Window size, expressed in the unit
#'   given by `window_unit`. Default `60`.
#' @param window_unit Character. One of `"min"`, `"hours"`, `"days"`.
#'   Values are internally normalised to minutes.
#' @param by_scenario Logical. Compute per scenario. Default `TRUE`.
#' @param by_group Logical. Stratify by `group` if the column is
#'   present. Default `TRUE`.
#' @param n_bootstrap Integer. Bootstrap replicates for CIs.
#'   Default `1000`; `0` omits intervals.
#'
#' @return A tibble with columns `scenario` (if stratified),
#'   `group` (if stratified), `ci`, `ci_ci_lo`, `ci_ci_hi`,
#'   `n_total`, `n_in_window`, `compliance_critical`, `window_min`.
#' @export
#' @examples
#' sim <- load_example_data()
#' ci  <- compute_compliance_index(sim)
compute_compliance_index <- function(entities,
                                     window_min  = 60,
                                     window_unit = c("min", "hours",
                                                     "days"),
                                     by_scenario = TRUE,
                                     by_group    = TRUE,
                                     n_bootstrap = 1000) {

  .validate_window(window_min, "window_min")
  .validate_n_boot(n_bootstrap)
  window_unit <- match.arg(window_unit)
  window_min_norm <- switch(window_unit,
    "min"   = window_min,
    "hours" = window_min * 60,
    "days"  = window_min * 1440
  )

  .validate_window(window_min_norm, "window in minutes")

  d <- if (inherits(entities, "dynasimR_data")) entities$entities
       else entities

  if (nrow(d) == 0)
    return(tibble::tibble())

  time_col <- if ("time_to_first_service" %in% names(d))
    "time_to_first_service" else if ("wait_days_to_min" %in% names(d))
    "wait_days_to_min" else NA_character_
  if (is.na(time_col))
    cli::cli_abort(
      "Entity table needs 'time_to_first_service' or ",
      "'wait_days_to_min'."
    )

  .validate_elapsed_time(d[[time_col]], time_col)
  if ("received_service" %in% names(d))
    .validate_binary(d$received_service, "received_service", allow_na = TRUE)

  group_vars <- character(0)
  if (by_scenario) group_vars <- c(group_vars, "scenario")
  if (by_group && "group" %in% names(d))
    group_vars <- c(group_vars, "group")

  compute_group <- function(sub) {
    t <- sub[[time_col]]
    in_win <- !is.na(t) & t <= window_min_norm
    if ("received_service" %in% names(sub))
      in_win <- in_win & !is.na(sub$received_service) & sub$received_service == 1
    n_total <- length(t)
    n_in    <- sum(in_win)
    ci <- if (n_total > 0) n_in / n_total else NA_real_
    ci_boot <- if (n_total > 1 && n_bootstrap > 0)
      .boot_quantile_ci(as.integer(in_win), n_bootstrap,
                        fun = mean)
    else c(NA_real_, NA_real_)
    tibble::tibble(
      n_total     = n_total,
      n_in_window = n_in,
      ci          = ci,
      ci_ci_lo    = ci_boot[1],
      ci_ci_hi    = ci_boot[2]
    )
  }

  if (length(group_vars) == 0) {
    result <- compute_group(d)
  } else {
    result <- d |>
      dplyr::group_by(dplyr::across(dplyr::all_of(group_vars))) |>
      dplyr::group_modify(~ compute_group(.x)) |>
      dplyr::ungroup()
  }

  result$compliance_critical <- !is.na(result$ci) & result$ci < 0.80
  result$window_min          <- window_min_norm
  result$window_unit         <- window_unit
  result
}
