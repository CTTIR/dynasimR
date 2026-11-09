#' Between-group prioritisation effect (Profile B)
#'
#' Compares two Profile B scenarios that differ only in inclusion
#' rules for which groups are prioritised, and returns completion
#' rates, the supplied cost metric and their differences (A minus B) with
#' bootstrap CIs. Cost is summarized as supplied, not divided by completion
#' rates. Replications are assumed independent and unpaired. Missing values
#' are omitted; each scenario needs at least one observed completion rate.
#' Intervals are unavailable with fewer than two observations per group.
#'
#' @param data A `dynasimR_data` object or summary tibble.
#' @param group_a_scenario Character. Scenario ID for group A
#'   priority.
#' @param group_b_scenario Character. Scenario ID for group B
#'   priority.
#' @param outcome_col Character. Column name for the completion
#'   outcome. Default `"completion_rate"`.
#' @param cost_col Character. Column name for cost metric.
#'   Default `"cost"`.
#' @param alpha Numeric. Significance level. Default `0.05`.
#' @param n_bootstrap Integer. Bootstrap replicates. Default `1000`; `0`
#'   omits confidence intervals.
#'
#' @return An S3 object of class `dynasimR_group_effect` with slots
#'   `completion`, `cost`, `delta_completion`, `delta_cost`,
#'   `params`.
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
#' ge <- group_effect(runs, group_a_scenario = "B-S01",
#'                    group_b_scenario = "B-S00", n_bootstrap = 200)
#' ge$delta_completion
#' @export
group_effect <- function(data,
                         group_a_scenario,
                         group_b_scenario,
                         outcome_col = "completion_rate",
                         cost_col    = "cost",
                         alpha       = 0.05,
                         n_bootstrap = 1000) {

  if (missing(group_a_scenario) || missing(group_b_scenario))
    cli::cli_abort(
      "Both {.arg group_a_scenario} and ",
      "{.arg group_b_scenario} required."
    )

  .validate_n_boot(n_bootstrap)
  if (!is.numeric(alpha) || length(alpha) != 1L || is.na(alpha) ||
      !is.finite(alpha) || alpha <= 0 || alpha >= 1)
    cli::cli_abort("{.arg alpha} must be between 0 and 1 (exclusive).")
  for (name in c("group_a_scenario", "group_b_scenario", "outcome_col", "cost_col")) {
    value <- get(name)
    if (!is.character(value) || length(value) != 1L || is.na(value) || !nzchar(value))
      cli::cli_abort("{.arg {name}} must be one nonempty character value.")
  }

  d <- if (inherits(data, "dynasimR_data")) data$summary else data
  .require_cols(d, c("scenario", outcome_col),
                where = "summary")
  .validate_rate(d[[outcome_col]], outcome_col)
  has_cost <- cost_col %in% names(d)
  if (has_cost) {
    value <- d[[cost_col]]
    if ((!is.numeric(value) && !(is.logical(value) && all(is.na(value)))) ||
        any(!is.na(value) & !is.finite(value)))
      cli::cli_abort("{.arg {cost_col}} must contain finite numeric values or NA.")
  }

  ga <- dplyr::filter(d, .data$scenario == group_a_scenario)
  gb <- dplyr::filter(d, .data$scenario == group_b_scenario)
  if (nrow(ga) == 0 || nrow(gb) == 0)
    cli::cli_abort(
      "Scenario {.val {group_a_scenario}} or ",
      "{.val {group_b_scenario}} not found."
    )

  a <- ga[[outcome_col]][!is.na(ga[[outcome_col]])]
  b <- gb[[outcome_col]][!is.na(gb[[outcome_col]])]
  if (length(a) == 0L || length(b) == 0L)
    cli::cli_abort("Each scenario needs at least one observed completion rate.")

  completion <- tibble::tibble(
    scenario = c(group_a_scenario, group_b_scenario),
    n        = c(length(a), length(b)),
    median   = c(stats::median(a, na.rm = TRUE),
                 stats::median(b, na.rm = TRUE)),
    q025     = c(stats::quantile(a, 0.025, na.rm = TRUE,
                                 names = FALSE),
                 stats::quantile(b, 0.025, na.rm = TRUE,
                                 names = FALSE)),
    q975     = c(stats::quantile(a, 0.975, na.rm = TRUE,
                                 names = FALSE),
                 stats::quantile(b, 0.975, na.rm = TRUE,
                                 names = FALSE))
  )

  d_ci <- if (length(a) > 1 && length(b) > 1)
    .boot_diff_ci(a, b, n_bootstrap, fun = stats::median,
                  probs = c(alpha / 2, 1 - alpha / 2))
  else c(NA_real_, NA_real_)

  delta_completion <- tibble::tibble(
    delta_median = stats::median(a, na.rm = TRUE) -
                   stats::median(b, na.rm = TRUE),
    ci_lo        = d_ci[1],
    ci_hi        = d_ci[2]
  )

  cost_out <- NULL
  delta_cost <- NULL
  if (has_cost) {
    ca <- ga[[cost_col]][!is.na(ga[[cost_col]])]
    cb <- gb[[cost_col]][!is.na(gb[[cost_col]])]
    cost_out <- tibble::tibble(
      scenario    = c(group_a_scenario, group_b_scenario),
      median_cost = c(stats::median(ca, na.rm = TRUE),
                      stats::median(cb, na.rm = TRUE))
    )
    dc_ci <- if (length(ca) > 1 && length(cb) > 1)
      .boot_diff_ci(ca, cb, n_bootstrap, fun = stats::median,
                    probs = c(alpha / 2, 1 - alpha / 2))
    else c(NA_real_, NA_real_)
    delta_cost <- tibble::tibble(
      delta_median = stats::median(ca, na.rm = TRUE) -
                     stats::median(cb, na.rm = TRUE),
      ci_lo        = dc_ci[1],
      ci_hi        = dc_ci[2]
    )
  }

  structure(
    list(
      completion       = completion,
      cost             = cost_out,
      delta_completion = delta_completion,
      delta_cost       = delta_cost,
      params           = list(
        group_a_scenario = group_a_scenario,
        group_b_scenario = group_b_scenario,
        outcome_col      = outcome_col,
        cost_col         = cost_col,
        alpha            = alpha,
        n_bootstrap      = n_bootstrap
      )
    ),
    class = c("dynasimR_group_effect", "list")
  )
}

#' Completion-outcome analysis (multinomial)
#'
#' Fits a multinomial logistic regression of completion outcome
#' (categorical) on scenario + covariates. Returns the model, tidied
#' coefficients, and class-level proportions.
#'
#' @param data A `dynasimR_data` object or entity tibble with a
#'   `completion_outcome` column (factor) and `scenario`. At least two
#'   observed outcome classes are required. Missing outcomes or model
#'   inputs and rank-deficient predictor designs are rejected rather than
#'   silently changing the fitted sample or model.
#' @param covariates Character vector. Additional predictors.
#'   Default `c("scenario", "severity")`. Every requested column must
#'   exist; predictors are interpreted as column names, not R expressions.
#' @return An S3 object of class `dynasimR_completion` with slots
#'   `fit`, `tidy`, `proportions`, `params`. Coefficient rows name the
#'   actual non-reference outcome classes; `params$reference_outcome` is
#'   the first factor level and `params$n_obs` is the analysed sample size.
#'   When the optional package `nnet` is unavailable, only proportions
#'   are returned with a warning.
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
#' ca <- compute_completion_analysis(entities)
#' ca$proportions
#' @export
compute_completion_analysis <- function(data,
                                        covariates = c("scenario",
                                                       "severity")) {

  d <- if (inherits(data, "dynasimR_data")) data$entities else data
  if (!"completion_outcome" %in% names(d))
    cli::cli_abort("Entity table needs 'completion_outcome' column.")

  .require_cols(d, "scenario", where = "entities")
  if (!is.character(covariates) || !length(covariates) || anyNA(covariates) ||
      any(!nzchar(covariates)) || anyDuplicated(covariates))
    cli::cli_abort("{.arg covariates} must contain unique, nonempty column names.")
  absent <- setdiff(covariates, names(d))
  if (length(absent)) {
    if (!length(intersect(covariates, names(d))))
      cli::cli_abort("No valid covariates in data; missing {.val {absent}}.")
    cli::cli_abort("Requested covariates not in data: {.val {absent}}.")
  }
  if ("completion_outcome" %in% covariates)
    cli::cli_abort("Predictors must not include the completion outcome itself.")
  for (column in unique(c("scenario", "completion_outcome", covariates))) {
    value <- d[[column]]
    if (anyNA(value) || (is.numeric(value) && any(!is.finite(value))))
      cli::cli_abort("Model column {.val {column}} must not contain missing or nonfinite values.")
  }
  d$completion_outcome <- droplevels(factor(d$completion_outcome))
  if (nlevels(d$completion_outcome) < 2L)
    cli::cli_abort("Completion analysis requires at least two observed outcome classes.")
  for (column in covariates) {
    if (length(unique(d[[column]])) < 2L)
      cli::cli_abort("Covariate {.val {column}} needs at least two observed values.")
    if (is.factor(d[[column]])) d[[column]] <- droplevels(d[[column]])
  }
  form <- stats::as.formula(paste("completion_outcome ~", .model_terms(covariates)))
  design <- stats::model.matrix(form, data = d)
  if (qr(design)$rank < ncol(design))
    cli::cli_abort("Completion model predictors are rank deficient; remove redundant covariates.")

  props <- d |>
    dplyr::group_by(.data$scenario, .data$completion_outcome) |>
    dplyr::summarise(n = dplyr::n(), .groups = "drop_last") |>
    dplyr::mutate(prop = .data$n / sum(.data$n)) |>
    dplyr::ungroup()

  fit <- NULL
  tidy_out <- NULL
  if (requireNamespace("nnet", quietly = TRUE)) {
    fit <- nnet::multinom(form, data = d, trace = FALSE)
    if (fit$convergence != 0L)
      cli::cli_abort("Completion model did not converge; inspect or rescale the predictors.")
    coefs <- stats::coef(fit)
    if (is.null(dim(coefs))) {
      coefs <- matrix(coefs, nrow = 1,
                      dimnames = list(fit$lev[2], names(coefs)))
    }
    tidy_out <- tibble::as_tibble(
      as.data.frame(coefs), rownames = "class"
    )
  } else {
    cli::cli_warn(
      "Package {.pkg nnet} not available; returning proportions only."
    )
  }

  structure(
    list(
      fit         = fit,
      tidy        = tidy_out,
      proportions = props,
      params      = list(covariates = covariates, n_obs = nrow(d),
                         outcome_levels = levels(d$completion_outcome),
                         reference_outcome = levels(d$completion_outcome)[1])
    ),
    class = c("dynasimR_completion", "list")
  )
}
