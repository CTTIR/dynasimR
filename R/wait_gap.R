#' Wait-Gap Index (Profile B)
#'
#' Analogue of the Compliance Index for entity-flow profiles:
#' fraction of entities whose wait time from arrival to activation
#' does not exceed a threshold number of days (default 14). A value
#' below `0.80` is flagged as a critical wait-gap. Missing wait times
#' remain in the denominator and do not count as timely activation;
#' negative or infinite waits are rejected. Supply observed activation
#' waits only: encode unactivated entities with `NA`, not a censoring
#' time. This index does not estimate a censoring-adjusted probability.
#'
#' @param data A `dynasimR_data` object or entity tibble with a
#'   `wait_days` column (or `wait_days_to_min` in minutes).
#' @param window_days Numeric. Allowed wait time in days.
#'   Default `14`.
#' @param by_scenario Logical. Stratify by scenario. Default `TRUE`.
#' @param by_cohort Logical. Stratify by `cohort` (if present).
#'   Default `TRUE`.
#' @param n_bootstrap Integer. Bootstrap replicates for CIs.
#'   Default `1000`; `0` omits intervals. Bootstrap intervals treat
#'   entities as independent observations, without replication clustering.
#'
#' @return A tibble with columns `scenario` (if stratified),
#'   `cohort` (if stratified), `wgi`, `wgi_ci_lo`, `wgi_ci_hi`,
#'   `n_total`, `n_in_window`, `wgi_critical`, `window_days`.
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
#' compute_wait_gap_index(entities, n_bootstrap = 200)
#' @export
compute_wait_gap_index <- function(data,
                                   window_days  = 14,
                                   by_scenario  = TRUE,
                                   by_cohort    = TRUE,
                                   n_bootstrap  = 1000) {

  .validate_window(window_days, "window_days")
  .validate_n_boot(n_bootstrap)
  d <- if (inherits(data, "dynasimR_data")) data$entities else data
  if (nrow(d) == 0) return(tibble::tibble())

  col <- if ("wait_days" %in% names(d)) "wait_days"
         else if ("wait_days_to_min" %in% names(d))
           "wait_days_to_min"
         else NA_character_
  if (is.na(col))
    cli::cli_abort(
      "Entity table needs 'wait_days' or 'wait_days_to_min'."
    )

  .validate_elapsed_time(d[[col]], col)

  # Normalise to days if column is in minutes
  vals <- if (col == "wait_days_to_min")
    d[[col]] / 1440 else d[[col]]

  d <- dplyr::mutate(d, .__wait = vals)

  group_vars <- character(0)
  if (by_scenario) {
    .require_cols(d, "scenario", where = "entities")
    group_vars <- c(group_vars, "scenario")
  }
  if (by_cohort && "cohort" %in% names(d))
    group_vars <- c(group_vars, "cohort")

  compute_group <- function(sub) {
    t <- sub$.__wait
    in_win <- !is.na(t) & t <= window_days
    n_total <- length(t)
    n_in    <- sum(in_win)
    wgi <- if (n_total > 0) n_in / n_total else NA_real_
    ci <- if (n_total > 1 && n_bootstrap > 0)
      .boot_quantile_ci(as.integer(in_win), n_bootstrap,
                        fun = mean)
    else c(NA_real_, NA_real_)
    tibble::tibble(
      n_total     = n_total,
      n_in_window = n_in,
      wgi         = wgi,
      wgi_ci_lo   = ci[1],
      wgi_ci_hi   = ci[2]
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

  result$wgi_critical <- !is.na(result$wgi) & result$wgi < 0.80
  result$window_days  <- window_days
  result
}
