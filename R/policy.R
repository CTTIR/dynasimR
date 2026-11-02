#' Quantify policy effect (policy A vs. policy B)
#'
#' Computes the full suite of effect metrics comparing two scenarios
#' that differ only in the allocation policy. Returns deltas on the
#' event rate and the Compliance Index, Cohen's d, risk differences
#' and an auto-generated narrative suitable for pasting into a
#' report. All event-rate differences are signed policy A minus B.
#' Cohen's d uses the independent-sample, degrees-of-freedom-weighted
#' pooled standard deviation. Bootstrap intervals and Wilcoxon tests
#' assume independent simulation replications, not paired runs.
#' `NNT_surrogate` is the reciprocal absolute mean rate difference;
#' its direction is supplied by `Risk_Difference_event`. Missing replicate
#' rates are omitted and effective counts are recorded. Each scenario
#' needs an observed rate; intervals and standardized effects need at least
#' two observations per scenario. Subgroup rates use the binary `event`
#' flag, or `status == "TERMINATED"` only when the flag column is absent.
#'
#' No hardcoded defaults are used - you **must** supply both scenario
#' IDs explicitly, so that the same function works for Profile A
#' (e.g. `"A-S08"` vs. `"A-S07"`) and Profile B (e.g. `"B-S19"` vs.
#' `"B-S00"`).
#'
#' @param data A `dynasimR_data` object or summary tibble.
#' @param policy_a_scenario Character. Scenario ID for policy A.
#' @param policy_b_scenario Character. Scenario ID for policy B
#'   (the comparator).
#' @param alpha Numeric. Significance level. Default `0.05`.
#' @param n_bootstrap Integer. Bootstrap replicates for CIs.
#'   Default `1000`; `0` omits intervals.
#'
#' @return An S3 object of class `dynasimR_policy` with slots
#'   `delta_event`, `compliance_comparison`, `effect_sizes`,
#'   `wilcoxon_tests`, `narrative`, and `params`.
#' @export
#' @examples
#' \dontrun{
#' sim <- load_example_data()
#' pol <- policy_effect(sim,
#'   policy_a_scenario = "A-S08", policy_b_scenario = "A-S07")
#' print(pol)
#' cat(pol$narrative)
#' }
policy_effect <- function(data,
                          policy_a_scenario,
                          policy_b_scenario,
                          alpha       = 0.05,
                          n_bootstrap = 1000) {

  if (missing(policy_a_scenario) || missing(policy_b_scenario))
    cli::cli_abort(
      "Both {.arg policy_a_scenario} and ",
      "{.arg policy_b_scenario} required."
    )

  .validate_n_boot(n_bootstrap)
  if (!is.numeric(alpha) || length(alpha) != 1L || is.na(alpha) ||
      !is.finite(alpha) || alpha <= 0 || alpha >= 1)
    cli::cli_abort("{.arg alpha} must be between 0 and 1 (exclusive).")

  d <- if (inherits(data, "dynasimR_data")) data$summary else data
  .require_cols(d, c("scenario", "event_rate"), where = "summary")
  .validate_rate(d$event_rate, "event_rate")
  if ("compliance_index" %in% names(d))
    .validate_rate(d$compliance_index, "compliance_index")

  a <- dplyr::filter(d, .data$scenario == policy_a_scenario)
  b <- dplyr::filter(d, .data$scenario == policy_b_scenario)

  if (nrow(a) == 0 || nrow(b) == 0)
    cli::cli_abort(
      "Scenario {.val {policy_a_scenario}} or ",
      "{.val {policy_b_scenario}} not found in data."
    )

  if (!any(is.finite(a$event_rate)) || !any(is.finite(b$event_rate)))
    cli::cli_abort("Each policy scenario needs at least one observed event rate.")

  delta_event <- .compute_delta_event(data,
    policy_a_scenario, policy_b_scenario, alpha, n_bootstrap)

  comp_cmp <- .compute_compliance_comparison(a, b,
    policy_a_scenario, policy_b_scenario, alpha, n_bootstrap)

  effects <- .compute_effect_sizes(a, b)

  wtests <- .wilcoxon_by_group(data,
    policy_a_scenario, policy_b_scenario, alpha)

  narrative <- .generate_policy_narrative(
    delta_event, comp_cmp, effects, wtests,
    policy_a_scenario, policy_b_scenario, alpha
  )

  structure(
    list(
      delta_event            = delta_event,
      compliance_comparison  = comp_cmp,
      effect_sizes           = effects,
      wilcoxon_tests         = wtests,
      narrative              = narrative,
      params                 = list(
        policy_a_scenario = policy_a_scenario,
        policy_b_scenario = policy_b_scenario,
        alpha             = alpha,
        n_bootstrap       = n_bootstrap,
        n_reps            = sum(is.finite(a$event_rate)),
        n_reps_b          = sum(is.finite(b$event_rate))
      )
    ),
    class = c("dynasimR_policy", "list")
  )
}

#' @export
print.dynasimR_policy <- function(x, ...) {
  cli::cli_h1("dynasimR_policy")
  cli::cli_bullets(c(
    "*" = "Policy A: {.val {x$params$policy_a_scenario}}",
    "*" = "Policy B: {.val {x$params$policy_b_scenario}}",
    "*" = "n (reps): {.val {x$params$n_reps}}"
  ))
  cli::cli_h2("Delta event rate")
  print(x$delta_event)
  cli::cli_h2("Narrative")
  cat(x$narrative, "\n")
  invisible(x)
}

## ---- Internal helpers ------------------------------------------------

#' @keywords internal
#' @noRd
.compute_delta_event <- function(data, a_id, b_id,
                                 alpha = 0.05, n_boot = 1000) {

  d <- if (inherits(data, "dynasimR_data")) data$summary else data
  a_sum <- dplyr::filter(d, .data$scenario == a_id)
  b_sum <- dplyr::filter(d, .data$scenario == b_id)

  # overall
  a_all <- a_sum$event_rate
  b_all <- b_sum$event_rate
  rows  <- list(
    tibble::tibble(
      group             = "all",
      median_pct_points = (stats::median(a_all, na.rm = TRUE) -
                           stats::median(b_all, na.rm = TRUE)) * 100
    )
  )
  if (length(a_all) > 1 && length(b_all) > 1) {
    ci <- .boot_diff_ci(a_all * 100, b_all * 100, n_boot,
                        fun = stats::median,
                        probs = c(alpha / 2, 1 - alpha / 2))
    rows[[1]]$ci_lo <- ci[1]
    rows[[1]]$ci_hi <- ci[2]
  } else {
    rows[[1]]$ci_lo <- NA_real_
    rows[[1]]$ci_hi <- NA_real_
  }

  # stratified - requires entity-level data
  ent <- if (inherits(data, "dynasimR_data")) data$entities else NULL
  if (!is.null(ent) && "group" %in% names(ent)) {
    ent$.__event <- .policy_entity_event(ent)
    strat <- ent |>
      dplyr::filter(.data$scenario %in% c(a_id, b_id)) |>
      dplyr::group_by(.data$scenario, .data$replication,
                      .data$group) |>
      dplyr::summarise(
        rate = mean(.data$.__event, na.rm = TRUE),
        .groups = "drop"
      )
    for (g in unique(strat$group)) {
      aa <- strat$rate[strat$scenario == a_id &
                       strat$group == g]
      bb <- strat$rate[strat$scenario == b_id &
                       strat$group == g]
      if (length(aa) == 0 || length(bb) == 0) next
      med_diff <- (stats::median(aa, na.rm = TRUE) -
                   stats::median(bb, na.rm = TRUE)) * 100
      if (length(aa) > 1 && length(bb) > 1) {
        ci <- .boot_diff_ci(aa * 100, bb * 100, n_boot,
                            fun = stats::median,
                            probs = c(alpha / 2, 1 - alpha / 2))
      } else {
        ci <- c(NA_real_, NA_real_)
      }
      rows[[length(rows) + 1]] <- tibble::tibble(
        group             = g,
        median_pct_points = med_diff,
        ci_lo             = ci[1],
        ci_hi             = ci[2]
      )
    }
  }
  dplyr::bind_rows(rows)
}

#' @keywords internal
#' @noRd
.compute_compliance_comparison <- function(a, b, a_id, b_id,
                                           alpha = 0.05,
                                           n_boot = 1000) {

  get_ci <- function(tbl)
    if ("compliance_index" %in% names(tbl))
      tbl$compliance_index else NA_real_

  ca <- get_ci(a)
  cb <- get_ci(b)
  ci_a <- .boot_quantile_ci(ca, n_boot,
                            probs = c(alpha / 2, 1 - alpha / 2))
  ci_b <- .boot_quantile_ci(cb, n_boot,
                            probs = c(alpha / 2, 1 - alpha / 2))

  tibble::tibble(
    scenario          = c(a_id, b_id),
    median_compliance = c(stats::median(ca, na.rm = TRUE),
                          stats::median(cb, na.rm = TRUE)),
    ci_lo             = c(ci_a[1], ci_b[1]),
    ci_hi             = c(ci_a[2], ci_b[2]),
    n                 = c(sum(is.finite(ca)), sum(is.finite(cb)))
  )
}

#' @keywords internal
#' @noRd
.compute_effect_sizes <- function(a, b) {
  aa <- a$event_rate[is.finite(a$event_rate)]
  bb <- b$event_rate[is.finite(b$event_rate)]
  pooled_sd <- if (length(aa) >= 2 && length(bb) >= 2) {
    sqrt(((length(aa) - 1) * stats::var(aa) +
          (length(bb) - 1) * stats::var(bb)) /
         (length(aa) + length(bb) - 2))
  } else NA_real_
  cohen_d <- if (is.finite(pooled_sd) && pooled_sd > 0)
    (mean(aa) - mean(bb)) / pooled_sd else NA_real_

  risk_diff <- mean(aa, na.rm = TRUE) - mean(bb, na.rm = TRUE)
  nnt <- if (!is.na(risk_diff) && risk_diff != 0)
    abs(1 / risk_diff) else NA_real_

  tibble::tibble(
    metric = c("Cohen_d_event", "Risk_Difference_event",
               "NNT_surrogate"),
    value  = c(cohen_d, risk_diff, nnt)
  )
}

#' @keywords internal
#' @noRd
.wilcoxon_by_group <- function(data, a_id, b_id, alpha = 0.05) {

  d <- if (inherits(data, "dynasimR_data")) data$summary else data

  # overall
  a_all <- d$event_rate[d$scenario == a_id]
  b_all <- d$event_rate[d$scenario == b_id]
  a_all <- a_all[is.finite(a_all)]
  b_all <- b_all[is.finite(b_all)]
  rows <- list()
  if (length(a_all) > 0 && length(b_all) > 0) {
    wt <- suppressWarnings(stats::wilcox.test(a_all, b_all,
                                              exact = FALSE))
    rows[[1]] <- tibble::tibble(
      group      = "all",
      statistic  = unname(wt$statistic),
      p_raw      = wt$p.value
    )
  }

  # stratified via entities - optional
  ent <- if (inherits(data, "dynasimR_data")) data$entities else NULL
  if (!is.null(ent) && "group" %in% names(ent)) {
    ent$.__event <- .policy_entity_event(ent)
    strat <- ent |>
      dplyr::filter(.data$scenario %in% c(a_id, b_id)) |>
      dplyr::group_by(.data$scenario, .data$replication,
                      .data$group) |>
      dplyr::summarise(
        rate = mean(.data$.__event, na.rm = TRUE),
        .groups = "drop"
      )
    for (g in unique(strat$group)) {
      aa <- strat$rate[strat$scenario == a_id &
                       strat$group == g]
      bb <- strat$rate[strat$scenario == b_id &
                       strat$group == g]
      aa <- aa[is.finite(aa)]
      bb <- bb[is.finite(bb)]
      if (length(aa) < 2 || length(bb) < 2) next
      wt <- suppressWarnings(stats::wilcox.test(aa, bb,
                                                exact = FALSE))
      rows[[length(rows) + 1]] <- tibble::tibble(
        group     = g,
        statistic = unname(wt$statistic),
        p_raw     = wt$p.value
      )
    }
  }

  if (length(rows) == 0)
    return(tibble::tibble(group = character(),
                          statistic = numeric(),
                          p_raw = numeric(),
                          p_adjusted = numeric()))

  out <- dplyr::bind_rows(rows)
  out$p_adjusted <- stats::p.adjust(out$p_raw, method = "BH")
  out
}

#' @keywords internal
#' @noRd
.generate_policy_narrative <- function(delta, comp, effects, tests,
                                       a_id, b_id, alpha = 0.05) {
  safe <- function(x) if (length(x) == 0) NA_real_ else x[1]
  all_row <- delta[delta$group == "all", ]
  d_med <- safe(all_row$median_pct_points)
  d_lo <- safe(all_row$ci_lo)
  d_hi <- safe(all_row$ci_hi)
  w_all <- tests[tests$group == "all", ]
  w_w <- safe(w_all$statistic)
  w_p <- safe(w_all$p_adjusted)
  c_a <- safe(comp$median_compliance[comp$scenario == a_id])
  c_b <- safe(comp$median_compliance[comp$scenario == b_id])

  direction <- if (!is.finite(d_med)) "unavailable" else if (d_med < 0)
    "lower under policy A" else if (d_med > 0) "higher under policy A" else
      "equal between the policies"
  interval <- if (all(is.finite(c(d_lo, d_hi))))
    glue::glue("{format(100 * (1 - alpha), trim = TRUE)}% CI: {round(d_lo, 1)} to {round(d_hi, 1)}") else
      "bootstrap CI unavailable"
  comparison <- if (!all(is.finite(c(c_a, c_b))))
    "The Compliance Index comparison was unavailable." else {
      comp_direction <- if (c_a > c_b) "higher" else if (c_a < c_b) "lower" else "equal"
      glue::glue("The Compliance Index was {comp_direction} under policy A ({round(c_a, 3)} vs. {round(c_b, 3)}).")
    }
  test <- if (is.finite(w_p))
    glue::glue("Wilcoxon test: W = {round(w_w, 0)}, adjusted p {.format_p(w_p)}") else
      "Wilcoxon test unavailable"
  as.character(glue::glue(
    "The policy A-minus-B event-rate difference (scenario {a_id} vs. {b_id}) ",
    "was {round(d_med, 1)} percentage points ({interval}); the event rate was ",
    "{direction} ({test}). {comparison}"
  ))
}

.policy_entity_event <- function(ent) {
  if ("event" %in% names(ent)) {
    .validate_binary(ent$event, "event", allow_na = TRUE)
    return(as.numeric(ent$event))
  }
  .require_cols(ent, "status", where = "entities")
  as.numeric(ent$status == "TERMINATED")
}
