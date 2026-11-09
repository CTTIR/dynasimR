#' Compute AL-Efficiency ratio (event reduction vs. compliance)
#'
#' Quantifies the trade-off between event-rate reduction and the
#' Compliance Index across autonomy levels AL0-AL5. Returns the
#' trade-off table, the optimal AL level (highest event reduction
#' still above the compliance threshold) and observed compliance violations.
#' Missing compliance is unknown, cannot qualify an optimum, and is not
#' labelled an observed violation. `al_ratio` is a descriptive ratio
#' `event_reduction_pct / (1 - compliance + 0.001)` with a fixed stabilizer;
#' it is not a validated utility or a criterion used to choose the optimum.
#' `event_ci_lo` and `event_ci_hi` describe absolute event rates.
#' `event_reduction_ci_lo` and `event_reduction_ci_hi` are percentile
#' intervals for the reference-minus-scenario median difference in
#' percentage points, assuming independent replications between scenarios.
#' The reference compared with itself has zero difference and, when an
#' interval is requested with at least two observed rates, bounds of zero.
#'
#' @param data A `dynasimR_data` object or summary tibble.
#' @param al_scenarios Named character vector. Mapping AL level (as
#'   a string) to scenario ID. Default assumes the Profile A
#'   scenarios (with the "A-" prefix).
#' @param compliance_threshold Numeric. Minimum Compliance Index for
#'   an AL level to be considered acceptable. Default `0.80`.
#' @param reference_al Integer. AL level used as reference for delta
#'   calculation. Default `0`.
#' @param n_bootstrap Integer. Bootstrap replicates for CIs.
#'   Default `1000`; `0` omits intervals.
#'
#' @return An S3 object of class `dynasimR_al_analysis` with slots
#'   `tradeoff_table`, `optimal_al`, `compliance_violations` and
#'   `params`.
#' @export
#' @examples
#' sim <- load_example_data()
#' al  <- al_efficiency(sim)
#' plot_al_tradeoff(al)
al_efficiency <- function(data,
                          al_scenarios  = c(
                            "0" = "A-S00", "1" = "A-S05",
                            "2" = "A-S09", "3" = "A-S10",
                            "4" = "A-S11", "5" = "A-S12"
                          ),
                          compliance_threshold = 0.80,
                          reference_al         = 0,
                          n_bootstrap          = 1000) {

  d <- if (inherits(data, "dynasimR_data")) data$summary else data

  .validate_n_boot(n_bootstrap)
  .require_cols(d, c("scenario", "event_rate"), where = "summary")
  .validate_rate(d$event_rate, "event_rate")
  if ("compliance_index" %in% names(d))
    .validate_rate(d$compliance_index, "compliance_index")
  .validate_rate(compliance_threshold, "compliance_threshold", allow_na = FALSE)
  if (length(compliance_threshold) != 1L)
    cli::cli_abort("{.arg compliance_threshold} must be one proportion.")
  levels <- names(al_scenarios)
  if (!is.character(al_scenarios) || !length(al_scenarios) ||
      is.null(levels) || anyNA(al_scenarios) || any(!nzchar(al_scenarios)) ||
      anyNA(levels) || any(!grepl("^[0-9]+$", levels)) ||
      anyDuplicated(levels) || anyNA(suppressWarnings(as.integer(levels))) ||
      anyDuplicated(suppressWarnings(as.integer(levels))))
    cli::cli_abort("{.arg al_scenarios} must map unique nonnegative integer AL names to scenario IDs.")
  if (length(reference_al) != 1L || is.na(reference_al) ||
      !as.character(reference_al) %in% levels)
    cli::cli_abort("Reference AL must be present in {.arg al_scenarios}.")
  ref_id <- al_scenarios[[as.character(reference_al)]]
  if (is.null(ref_id) || !ref_id %in% d$scenario)
    cli::cli_abort(
      "Reference AL{reference_al} scenario {.val {ref_id}} not in data."
    )

  ref_rates <- d$event_rate[d$scenario == ref_id]
  ref_event <- stats::median(ref_rates, na.rm = TRUE)

  if (!is.finite(ref_event))
    cli::cli_abort("The reference scenario needs an observed event rate.")

  tradeoff <- purrr::map_dfr(names(al_scenarios), function(al_str) {
    sc <- al_scenarios[[al_str]]
    sc_data <- dplyr::filter(d, .data$scenario == sc)
    if (nrow(sc_data) == 0) return(NULL)

    event_med <- stats::median(sc_data$event_rate, na.rm = TRUE)
    event_ci  <- if (nrow(sc_data) > 1)
      .boot_quantile_ci(sc_data$event_rate, n_bootstrap)
    else c(NA_real_, NA_real_)

    comp_med <- if ("compliance_index" %in% names(sc_data))
      stats::median(sc_data$compliance_index, na.rm = TRUE)
    else NA_real_

    event_red <- (ref_event - event_med) * 100
    reduction_ci <- if (sc == ref_id) {
      if (n_bootstrap > 0 && sum(is.finite(ref_rates)) >= 2L) c(0, 0)
      else c(NA_real_, NA_real_)
    } else {
      .boot_diff_ci(ref_rates * 100, sc_data$event_rate * 100, n_bootstrap)
    }
    above     <- if (is.na(comp_med)) NA else comp_med >= compliance_threshold

    tibble::tibble(
      al                   = as.integer(al_str),
      scenario             = sc,
      event_median         = event_med,
      event_ci_lo          = event_ci[1],
      event_ci_hi          = event_ci[2],
      event_reduction_pct  = event_red,
      event_reduction_ci_lo = reduction_ci[1],
      event_reduction_ci_hi = reduction_ci[2],
      compliance           = comp_med,
      above_threshold      = above,
      al_ratio             = if (isTRUE(above))
                                event_red /
                                (1 - comp_med + 0.001)
                              else NA_real_,
      n_reps               = nrow(sc_data)
    )
  })

  optimal <- tradeoff |>
    dplyr::filter(.data$above_threshold, is.finite(.data$event_reduction_pct)) |>
    dplyr::slice_max(.data$event_reduction_pct, n = 1,
                     with_ties = FALSE) |>
    dplyr::pull(.data$al)
  if (length(optimal) == 0) optimal <- NA_integer_

  violations <- tradeoff |>
    dplyr::filter(!.data$above_threshold) |>
    dplyr::mutate(compliance_deficit =
                    compliance_threshold - .data$compliance)

  structure(
    list(
      tradeoff_table         = tradeoff,
      optimal_al             = optimal,
      compliance_violations  = violations,
      compliance_threshold   = compliance_threshold,
      params                 = list(
        al_scenarios         = al_scenarios,
        compliance_threshold = compliance_threshold,
        reference_al         = reference_al,
        n_bootstrap          = n_bootstrap,
        omitted_scenarios    = setdiff(unname(al_scenarios), d$scenario)
      )
    ),
    class = c("dynasimR_al_analysis", "list")
  )
}

#' @export
print.dynasimR_al_analysis <- function(x, ...) {
  cli::cli_h1("dynasimR_al_analysis")
  cli::cli_bullets(c(
    "*" = "Compliance threshold: {.val {x$compliance_threshold}}",
    "*" = "Optimal AL: {.val {x$optimal_al}}",
    "*" = "Compliance violations: {.val {nrow(x$compliance_violations)}}"
  ))
  print(x$tradeoff_table)
  invisible(x)
}
