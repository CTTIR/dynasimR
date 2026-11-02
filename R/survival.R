#' Kaplan-Meier estimator for simulation data
#'
#' Estimates survival functions from simulated entity outcomes.
#' Supports several endpoints for both output profiles.
#'
#' @param data A `dynasimR_data` object or a tibble/data.frame
#'   containing entity-level columns. Endpoint times must be nonnegative
#'   finite observed event or censoring times, with binary 0/1 event flags.
#'   Missing times, flags or strata are rejected, not silently omitted.
#' @param scenarios Character vector. Restrict to these scenario IDs.
#'   Default `NULL` = all.
#' @param endpoint Character. One of `"stage2"`, `"overall"`,
#'   `"service"`, `"regression"`, `"completion"`, `"phase_c"`.
#'   The latter three are Profile-B-only endpoints.
#' @param stratify_by Character vector. Strata variables, e.g.
#'   `"scenario"` or `c("scenario", "group")`. Use `character()`
#'   for a pooled curve. A log-rank p-value is unavailable for one stratum
#'   or when no events were observed.
#' @param ci_method Character. Passed to [survival::survfit()] as
#'   `conf.type`. Default `"log"`.
#' @param n_bootstrap Integer. Bootstrap replicates for pointwise 95%
#'   percentile bands, resampling entities within each stratum. `0`
#'   omits bootstrap bands (default). Entities are assumed independent;
#'   this does not account for dependence within simulation replications.
#' @param seed Integer. RNG seed for bootstrap. Default `42`; a supplied
#'   seed preserves the caller's RNG state. `NULL` uses the current RNG.
#'
#' @return An S3 object of class `dynasimR_km` (list) with slots
#'   `fit`, `tidy`, `logrank`, `median_survival`, `boot_ci` and
#'   `params`. `boot_ci` contains `strata`, `time`, `estimate`,
#'   `conf.low`, `conf.high` and successful replicate count `n_boot`,
#'   evaluated at time zero and the original observed times of each stratum.
#'   Bands are unavailable for a stratum with fewer than two entities.
#'   `tidy` retains the analytic intervals selected by `ci_method`.
#' @export
#' @examples
#' \dontrun{
#' sim <- load_example_data()
#' km <- km_estimate(sim, endpoint = "stage2",
#'                   stratify_by = "scenario")
#' print(km)
#' plot_km(km)
#' }
km_estimate <- function(data,
                        scenarios   = NULL,
                        endpoint    = c("stage2", "overall", "service",
                                        "regression", "completion",
                                        "phase_c"),
                        stratify_by = "scenario",
                        ci_method   = "log",
                        n_bootstrap = 0,
                        seed        = 42) {

  endpoint <- match.arg(endpoint)
  .validate_n_boot(n_bootstrap)
  stratify_by <- unique(stratify_by)

  d <- if (inherits(data, "dynasimR_data")) data$entities else data

  if (!is.null(scenarios))
    d <- dplyr::filter(d, .data$scenario %in% scenarios)

  if (nrow(d) == 0)
    cli::cli_abort("No entity rows after filtering.")

  ## Endpoint -> column names --------------------------------------------
  time_col <- switch(endpoint,
    "stage2"     = "time_to_stage2",
    "overall"    = "event_time",
    "service"    = "time_to_first_service",
    "regression" = "time_to_regression",
    "completion" = "time_to_completion",
    "phase_c"    = "time_to_phase_c"
  )
  event_col <- switch(endpoint,
    "stage2"     = "reached_stage2",
    "overall"    = "event",
    "service"    = "received_service",
    "regression" = "regressed",
    "completion" = "completed",
    "phase_c"    = "reached_phase_c"
  )

  .require_cols(d, c(time_col, event_col, stratify_by),
                where = "entities")

  .validate_survival_data(d, time_col, event_col, stratify_by)
  strat_str <- if (length(stratify_by)) .model_terms(stratify_by) else "1"
  f <- stats::as.formula(
    glue::glue("survival::Surv({time_col}, {event_col}) ~ {strat_str}")
  )

  fit <- survival::survfit(f, data = d, conf.type = ci_method)

  tidy_df <- .km_tidy(fit)
  lr      <- .logrank_test(f, d, fit)
  meds    <- .extract_medians(fit)
  if (is.null(fit$strata)) {
    label <- as.character(.km_groups(d, stratify_by))[1]
    tidy_df$strata <- label
    meds$strata <- label
  }

  boot_ci <- NULL
  if (n_bootstrap > 0)
    boot_ci <- .bootstrap_km_ci(d, f, n_bootstrap, seed, stratify_by)

  structure(
    list(
      fit             = fit,
      tidy            = tidy_df,
      logrank         = lr,
      median_survival = meds,
      boot_ci         = boot_ci,
      params          = list(
        endpoint    = endpoint,
        stratify_by = stratify_by,
        ci_method   = ci_method,
        n_scenarios = if ("scenario" %in% names(d)) length(unique(d$scenario)) else NA_integer_,
        n_obs       = sum(fit$n),
        n_bootstrap = n_bootstrap,
        bootstrap_method = "pointwise 95% percentile bands within strata",
        seed        = seed
      )
    ),
    class = c("dynasimR_km", "list")
  )
}

#' @export
print.dynasimR_km <- function(x, ...) {
  cli::cli_h1("dynasimR_km")
  cli::cli_bullets(c(
    "*" = "Endpoint: {.val {x$params$endpoint}}",
    "*" = "Stratify by: {.val {x$params$stratify_by}}",
    "*" = "N scenarios: {.val {x$params$n_scenarios}}",
    "*" = "N observations: {.val {x$params$n_obs}}",
    "*" = "Log-rank p: {.val {signif(x$logrank$p_value, 3)}}"
  ))
  invisible(x)
}

#' @export
plot.dynasimR_km <- function(x, ...) plot_km(x, ...)

#' Cox proportional-hazards model for simulation data
#'
#' @param data A `dynasimR_data` object or entity tibble. Endpoint times
#'   must be nonnegative finite observed event or censoring times; flags
#'   must be 0 (censored) or 1 (event). Missing times, flags, strata, or
#'   model covariates are rejected rather than silently dropping entities.
#' @param endpoint See [km_estimate()].
#' @param covariates Character vector. Covariates entering the Cox
#'   model. Default `c("scenario","severity","group")`; unavailable
#'   defaults are omitted with a warning for profile compatibility.
#'   Explicitly requested unavailable covariates are an error.
#' @param reference_scenario Character. Reference level for the
#'   `scenario` factor. Default `"A-S00"`. Use `"B-S00"` for Profile B.
#' @return An S3 object of class `dynasimR_cox` with slots `fit`,
#'   `tidy`, `ph_test`, `forest_data` and `params`.
#' @export
cox_model <- function(data,
                      endpoint           = c("stage2", "overall",
                                             "service"),
                      covariates         = c("scenario",
                                             "severity",
                                             "group"),
                      reference_scenario = "A-S00") {

  endpoint <- match.arg(endpoint)
  d <- if (inherits(data, "dynasimR_data")) data$entities else data

  default_covariates <- missing(covariates)
  absent <- setdiff(covariates, names(d))
  if (length(absent)) {
    if (!default_covariates)
      cli::cli_abort("Requested covariates not in data: {.val {absent}}.")
    cli::cli_warn("Default covariates not in data and omitted: {.val {absent}}.")
    covariates <- setdiff(covariates, absent)
  }
  if (length(covariates) == 0)
    cli::cli_abort("None of the requested covariates are in data.")

  if ("scenario" %in% covariates) {
    if (length(reference_scenario) != 1L || is.na(reference_scenario) ||
        !reference_scenario %in% d$scenario)
      cli::cli_abort("Reference scenario {.val {reference_scenario}} not in data.")
    d$scenario <- stats::relevel(factor(d$scenario), ref = reference_scenario)
  }

  time_col <- switch(endpoint,
    "stage2"  = "time_to_stage2",
    "overall" = "event_time",
    "service" = "time_to_first_service"
  )
  event_col <- switch(endpoint,
    "stage2"  = "reached_stage2",
    "overall" = "event",
    "service" = "received_service"
  )

  .require_cols(d, c(time_col, event_col), where = "entities")

  .validate_survival_data(d, time_col, event_col, covariates)
  if (!any(d[[event_col]] == 1))
    cli::cli_abort("A Cox model requires at least one observed event.")
  cov_str <- .model_terms(covariates)
  f <- stats::as.formula(
    glue::glue("survival::Surv({time_col}, {event_col}) ~ {cov_str}")
  )

  fit    <- survival::coxph(f, data = d, singular.ok = FALSE)
  ph_res <- survival::cox.zph(fit)

  tidy_hr <- .cox_tidy(fit)
  forest  <- dplyr::filter(tidy_hr, grepl("scenario", .data$term)) |>
    dplyr::mutate(term = sub("scenario", "", .data$term))

  structure(
    list(
      fit         = fit,
      tidy        = tidy_hr,
      ph_test     = .phtest_tidy(ph_res),
      forest_data = forest,
      params      = list(
        endpoint           = endpoint,
        covariates         = covariates,
        reference_scenario = if ("scenario" %in% covariates) reference_scenario else NULL,
        n_obs              = fit$n
      )
    ),
    class = c("dynasimR_cox", "list")
  )
}

#' @export
print.dynasimR_cox <- function(x, ...) {
  cli::cli_h1("dynasimR_cox")
  cli::cli_bullets(c(
    "*" = "Endpoint: {.val {x$params$endpoint}}",
    "*" = "Covariates: {.val {x$params$covariates}}",
    "*" = "Reference: {.val {x$params$reference_scenario}}",
    "*" = "N: {.val {x$params$n_obs}}"
  ))
  print(x$tidy)
  invisible(x)
}

## ---- Internal helpers ------------------------------------------------

#' @keywords internal
#' @noRd
.km_tidy <- function(fit) {
  if (!is.null(fit$lower) && !is.null(fit$upper) &&
      requireNamespace("broom", quietly = TRUE)) {
    out <- tibble::as_tibble(broom::tidy(fit))
    if (!"strata" %in% names(out)) out$strata <- "all"
    return(out)
  }

  # Manual fallback -------------------------------------------------------
  s <- summary(fit, censored = TRUE)
  strata <- if (is.null(s$strata)) rep("all", length(s$time))
            else as.character(s$strata)
  tibble::tibble(
    time      = s$time,
    n.risk    = s$n.risk,
    n.event   = s$n.event,
    n.censor  = s$n.censor,
    estimate  = s$surv,
    conf.low  = if (is.null(s$lower)) NA_real_ else s$lower,
    conf.high = if (is.null(s$upper)) NA_real_ else s$upper,
    strata    = strata
  )
}

#' @keywords internal
#' @noRd
.cox_tidy <- function(fit) {
  if (requireNamespace("broom", quietly = TRUE)) {
    out <- broom::tidy(fit, exponentiate = TRUE, conf.int = TRUE)
  } else {
    coefs <- summary(fit)$coefficients
    ci    <- summary(fit)$conf.int
    out <- tibble::tibble(
      term      = rownames(coefs),
      estimate  = ci[, 1],
      std.error = coefs[, 3],
      statistic = coefs[, 4],
      p.value   = coefs[, 5],
      conf.low  = ci[, 3],
      conf.high = ci[, 4]
    )
  }
  dplyr::rename(out, HR = "estimate",
                CI_low = "conf.low", CI_high = "conf.high") |>
    dplyr::mutate(sig = dplyr::case_when(
      p.value < 0.001 ~ "***",
      p.value < 0.01  ~ "**",
      p.value < 0.05  ~ "*",
      TRUE            ~ "ns"
    ))
}

#' @keywords internal
#' @noRd
.phtest_tidy <- function(ph_res) {
  tab <- ph_res$table
  tibble::tibble(
    term        = rownames(tab),
    chisq       = tab[, "chisq"],
    df          = tab[, "df"],
    p.value     = tab[, "p"]
  )
}

#' @keywords internal
#' @noRd
.logrank_test <- function(formula, data, fit) {
  n_groups <- if (is.null(fit$strata)) 1L else length(fit$strata)
  if (n_groups < 2 || sum(fit$n.event) == 0)
    return(tibble::tibble(chisq = NA_real_, df = n_groups - 1L,
                          p_value = NA_real_))
  res <- survival::survdiff(formula, data = data)
  expected <- if (is.matrix(res$exp)) rowSums(res$exp) else res$exp
  df <- sum(expected > 0) - 1L
  pval <- if (df > 0 && is.finite(res$chisq))
    stats::pchisq(res$chisq, df, lower.tail = FALSE) else NA_real_
  tibble::tibble(chisq = res$chisq, df = df, p_value = pval)
}

#' @keywords internal
#' @noRd
.extract_medians <- function(fit) {
  s <- summary(fit)$table
  if (is.null(dim(s))) {
    med <- unname(s["median"])
    return(tibble::tibble(strata = "all", median = med))
  }
  tibble::tibble(
    strata = rownames(s),
    median = s[, "median"]
  )
}

#' @keywords internal
#' @noRd
.bootstrap_km_ci <- function(data, formula, n_boot, seed = 42,
                              stratify_by = character()) {
  groups <- .km_groups(data, stratify_by)
  ids <- split(seq_len(nrow(data)), groups, drop = TRUE)
  pooled_formula <- stats::update(formula, . ~ 1)
  .with_boot_seed(seed, {
    dplyr::bind_rows(lapply(names(ids), function(label) {
      sub <- data[ids[[label]], , drop = FALSE]
      response <- stats::model.response(stats::model.frame(pooled_formula, sub))
      grid <- sort(unique(c(0, response[, 1])))
      original <- survival::survfit(pooled_formula, data = sub)
      estimate <- summary(original, times = grid, extend = TRUE)$surv
      if (nrow(sub) < 2) {
        lower <- upper <- rep(NA_real_, length(grid))
        n_used <- 0L
      } else {
        draws <- vapply(seq_len(n_boot), function(i) {
          sampled <- sub[sample.int(nrow(sub), nrow(sub), replace = TRUE), , drop = FALSE]
          fit <- survival::survfit(pooled_formula, data = sampled)
          summary(fit, times = grid, extend = TRUE)$surv
        }, numeric(length(grid)))
        draws <- matrix(draws, nrow = length(grid))
        bounds <- apply(draws, 1, stats::quantile, probs = c(0.025, 0.975),
                        names = FALSE)
        lower <- bounds[1, ]
        upper <- bounds[2, ]
        n_used <- n_boot
      }
      tibble::tibble(strata = label, time = grid, estimate = estimate,
                    conf.low = lower, conf.high = upper, n_boot = n_used)
    }))
  })
}

.km_groups <- function(data, stratify_by) {
  if (length(stratify_by))
    do.call(survival::strata,
            c(as.list(data[stratify_by]), list(shortlabel = FALSE)))
  else factor(rep("all", nrow(data)))
}

.model_terms <- function(columns) {
  paste(vapply(columns, function(x) deparse(as.name(x), backtick = TRUE),
               character(1)), collapse = " + ")
}

.validate_survival_data <- function(data, time_col, event_col, model_cols) {
  .validate_elapsed_time(data[[time_col]], time_col, allow_na = FALSE)
  .validate_binary(data[[event_col]], event_col)
  for (column in model_cols) {
    value <- data[[column]]
    if (anyNA(value) || (is.numeric(value) && any(!is.finite(value))))
      cli::cli_abort("Model column {.val {column}} must not contain missing or nonfinite values.")
  }
}

#' @keywords internal
#' @noRd
.km_caption <- function(km_result, show_pval = TRUE) {
  base <- glue::glue(
    "n = {km_result$params$n_obs}, ",
    "scenarios = {km_result$params$n_scenarios}, ",
    "endpoint = {km_result$params$endpoint}"
  )
  if (show_pval && !is.null(km_result$logrank) &&
      is.finite(km_result$logrank$p_value)) {
    pv <- km_result$logrank$p_value
    pvt <- .format_p(pv)
    base <- paste0(base, "; log-rank p ", pvt)
  }
  base
}
