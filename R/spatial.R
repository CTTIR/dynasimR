#' Supply-Demand Index (SDI) per region
#'
#' Computes the ratio of available service capacity to positive demand.
#' Values > 1 indicate oversupply, values < 1 undersupply, and equal
#' supply and demand give exactly 1. Rows with zero demand have an
#' undefined ratio and are excluded from SDI summaries; a region with
#' no valid ratio has `NA` SDI and `NA` undersupply status.
#'
#' @param data A `dynasimR_data` object or summary tibble with
#'   `region`, `supply` and `demand` columns. Observed supply and demand
#'   must be finite and nonnegative. Missing values are allowed.
#' @param region_col Character. Region column name. Default `"region"`.
#' @param supply_col Character. Supply column name. Default `"supply"`.
#' @param demand_col Character. Demand column name. Default `"demand"`.
#' @param eps Deprecated compatibility argument. No offset is applied:
#'   adding an offset changes the ratio even when demand is positive.
#'
#' @return A tibble with the region column, `supply_median`,
#'   `demand_median`, `sdi_median`, `sdi_q025`, `sdi_q975`,
#'   `undersupply`, `n_observed` (valid paired ratios) and
#'   `n_zero_demand`. The interval is the observed 2.5th to 97.5th
#'   percentile range, not a confidence interval for the median.
#' @export
spatial_supply_demand <- function(data,
                                  region_col = "region",
                                  supply_col = "supply",
                                  demand_col = "demand",
                                  eps = 1) {
  if (!missing(eps))
    cli::cli_warn("{.arg eps} is deprecated and no longer changes the SDI.")
  d <- if (inherits(data, "dynasimR_data")) data$summary else data
  .require_cols(d, c(region_col, supply_col, demand_col), where = "summary")
  for (col in c(supply_col, demand_col)) {
    value <- d[[col]]
    if ((!is.numeric(value) && !(is.logical(value) && all(is.na(value)))) ||
        any(!is.na(value) & (!is.finite(value) | value < 0)))
      cli::cli_abort("{.field {col}} must contain nonnegative finite values or NA.")
  }
  ratio <- rep(NA_real_, nrow(d))
  observed <- !is.na(d[[supply_col]]) & !is.na(d[[demand_col]]) &
    d[[demand_col]] > 0
  ratio[observed] <- d[[supply_col]][observed] / d[[demand_col]][observed]
  if (any(!is.na(ratio) & !is.finite(ratio)))
    cli::cli_abort("Supply/demand ratios exceed the numeric range.")
  d$.__sdi <- ratio
  d |>
    dplyr::group_by(dplyr::across(dplyr::all_of(region_col))) |>
    dplyr::summarise(
      supply_median = stats::median(.data[[supply_col]], na.rm = TRUE),
      demand_median = stats::median(.data[[demand_col]], na.rm = TRUE),
      sdi_median = stats::median(.data$.__sdi, na.rm = TRUE),
      sdi_q025 = stats::quantile(.data$.__sdi, 0.025,
                                 na.rm = TRUE, names = FALSE),
      sdi_q975 = stats::quantile(.data$.__sdi, 0.975,
                                 na.rm = TRUE, names = FALSE),
      n_observed = sum(!is.na(.data$.__sdi)),
      n_zero_demand = sum(.data[[demand_col]] == 0, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(undersupply = .data$sdi_median < 1)
}
