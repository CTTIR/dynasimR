#' Standardized univariate sensitivity screening
#'
#' Fits a separate linear association between each input and the outcome,
#' after standardizing paired complete observations. Despite its legacy
#' name, this function does not implement Morris elementary effects or
#' a variance decomposition. It can miss nonlinear effects and cannot
#' separate correlated inputs or establish causality. For a Morris design
#' use `sensitivity::morris()` on an appropriate simulation design.
#'
#' @param data A `dynasimR_data` object or summary tibble.
#' @param outcome Character. Column name of the outcome to screen.
#'   Default `"event_rate"`.
#' @param inputs Character vector. Numeric simulation input columns.
#'   Each input needs at least three paired complete observations and
#'   variation in both the input and outcome; otherwise its statistics
#'   and rank are `NA`, with a reason in `status` and a warning.
#'
#' @return A tibble with `input`, legacy `mu_star` (absolute standardized
#'   slope, equal to absolute Pearson correlation), legacy `sigma`
#'   (standardized regression residual SD), `r2`, `n_observed`, `status`
#'   and `rank`. Missing pairs are omitted independently for each input.
#' @examples
#' sim <- load_example_data()
#' morris_screening(sim, outcome = "event_rate",
#'                  inputs = c("al", "event_base"))
#' @export
morris_screening <- function(data,
                             outcome = "event_rate",
                             inputs) {
  d <- if (inherits(data, "dynasimR_data")) data$summary else data
  if (!is.character(inputs) || length(inputs) == 0L || anyNA(inputs) ||
      any(!nzchar(inputs)) || anyDuplicated(inputs))
    cli::cli_abort("{.arg inputs} must contain unique, nonempty column names.")
  .require_cols(d, c(outcome, inputs), where = "summary")
  for (nm in c(outcome, inputs)) {
    value <- d[[nm]]
    if ((!is.numeric(value) && !(is.logical(value) && all(is.na(value)))) ||
        any(!is.na(value) & !is.finite(value)))
      cli::cli_abort("{.field {nm}} must contain finite numeric observations or NA.")
  }
  out <- purrr::map_dfr(inputs, function(nm) {
    paired <- !is.na(d[[outcome]]) & !is.na(d[[nm]])
    x <- d[[nm]][paired]
    y <- d[[outcome]][paired]
    n <- length(x)
    status <- if (n < 3L) "insufficient paired observations"
              else if (stats::sd(x) == 0) "constant input"
              else if (stats::sd(y) == 0) "constant outcome"
              else "ok"
    if (status != "ok") {
      cli::cli_warn("Cannot screen {.val {nm}}: {status}.")
      return(tibble::tibble(input = nm, mu_star = NA_real_, sigma = NA_real_,
                            r2 = NA_real_, n_observed = n, status = status))
    }
    x <- as.numeric(scale(x))
    y <- as.numeric(scale(y))
    fit <- stats::lm(y ~ x)
    r2 <- stats::cor(x, y)^2
    tibble::tibble(
      input = nm, mu_star = abs(unname(stats::coef(fit)[2])),
      sigma = sqrt(sum(stats::residuals(fit)^2) / (n - 2L)),
      r2 = r2, n_observed = n, status = status
    )
  })
  out <- dplyr::arrange(out, dplyr::desc(.data$mu_star))
  out$rank <- ifelse(is.na(out$mu_star), NA_integer_, seq_len(nrow(out)))
  out
}

#' Tornado-diagram data from one-at-a-time perturbation
#'
#' Given a baseline scenario and perturbation scenarios, computes the
#' change in the outcome metric for each perturbation relative to the
#' baseline.
#'
#' @param data A `dynasimR_data` object or summary tibble.
#' @param baseline Character. Scenario ID of the baseline.
#' @param perturbations Character vector. Scenario IDs of
#'   one-at-a-time perturbations.
#' @param outcome Character. Column name of the outcome to measure.
#'   Default `"event_rate"`.
#'
#' @return A tibble suitable for a tornado plot with columns
#'   `scenario`, `delta`, `lo`, `hi`, sorted by absolute delta. `lo` and
#'   `hi` are the perturbation's observed percentile range minus the fixed
#'   baseline median, not a confidence interval for their difference.
#' @examples
#' sim <- load_example_data()
#' tornado_data(sim, baseline = "A-S00",
#'              perturbations = c("A-S07", "A-S08"))
#' @export
tornado_data <- function(data,
                         baseline,
                         perturbations,
                         outcome = "event_rate") {

  d <- if (inherits(data, "dynasimR_data")) data$summary else data
  .require_cols(d, c("scenario", outcome), where = "summary")

  if (!is.numeric(d[[outcome]]) ||
      any(!is.na(d[[outcome]]) & !is.finite(d[[outcome]])))
    cli::cli_abort("{.field {outcome}} must contain finite numeric values or NA.")
  base <- d[[outcome]][!is.na(d$scenario) & d$scenario == baseline]
  if (length(base) == 0)
    cli::cli_abort("Baseline {.val {baseline}} not in data.")
  if (all(is.na(base)))
    cli::cli_abort("Baseline {.val {baseline}} has no observed outcome values.")
  base_med <- stats::median(base, na.rm = TRUE)

  empty <- tibble::tibble(scenario = character(), delta = double(),
                          lo = double(), hi = double())
  out <- purrr::map_dfr(perturbations, function(sc) {
    vals <- d[[outcome]][!is.na(d$scenario) & d$scenario == sc]
    if (length(vals) == 0) return(NULL)
    med <- stats::median(vals, na.rm = TRUE)
    q <- stats::quantile(vals, c(0.025, 0.975),
                         na.rm = TRUE, names = FALSE)
    tibble::tibble(
      scenario = sc,
      delta    = med - base_med,
      lo       = q[1] - base_med,
      hi       = q[2] - base_med
    )
  })
  dplyr::bind_rows(empty, out) |>
    dplyr::arrange(dplyr::desc(abs(.data$delta)))
}
