policy_fixture <- function() {
  tibble::tibble(scenario = rep(c("A", "B"), each = 3),
                event_rate = c(.7, .8, .9, .1, .2, .3),
                compliance_index = c(.2, .3, .4, .8, .9, 1))
}

survival_fixture <- function() {
  tibble::tibble(scenario = rep(c("A", "B", "C"), each = 2),
                time_to_stage2 = 1:6,
                reached_stage2 = c(1L, 0L, 1L, 1L, 0L, 0L))
}

test_that("policy narrative follows direction and requested confidence", {
  d <- policy_fixture()
  set.seed(40)
  p <- policy_effect(d, "A", "B", alpha = .2, n_bootstrap = 20)
  expect_equal(p$delta_event$median_pct_points, 60)
  expect_match(p$narrative, "80% CI", fixed = TRUE)
  expect_match(p$narrative, "higher under policy A")
  expect_match(p$narrative, "Compliance Index was lower")
  reverse <- policy_effect(d, "B", "A", n_bootstrap = 0)
  expect_equal(reverse$delta_event$median_pct_points, -60)
  expect_match(reverse$narrative, "event rate was lower")
  expect_match(reverse$narrative, "Compliance Index was higher")
  expect_true(all(is.na(reverse$delta_event$ci_lo)))
  d$event_rate[d$scenario == "B"] <- d$event_rate[d$scenario == "A"]
  d$compliance_index <- NULL
  tie <- policy_effect(d, "A", "B", n_bootstrap = 0)
  expect_match(tie$narrative, "equal between the policies")
  expect_match(tie$narrative, "Compliance Index comparison was unavailable")
})

test_that("policy point estimates survive singleton samples and d weights unequal sizes", {
  d <- policy_fixture()[c(1, 4), ]
  p <- policy_effect(d, "A", "B", n_bootstrap = 0)
  expect_equal(p$delta_event$median_pct_points, 60)
  expect_true(is.na(p$effect_sizes$value[p$effect_sizes$metric == "Cohen_d_event"]))
  expect_equal(p$effect_sizes$value[p$effect_sizes$metric == "Risk_Difference_event"], .6)
  a <- c(.1, .2)
  b <- seq(.1, .8, .1)
  eff <- .compute_effect_sizes(data.frame(event_rate = a), data.frame(event_rate = b))
  expect_equal(eff$value[1], -1.301582746911937)
})

test_that("policy compliance interval bounds come from the same bootstrap draws", {
  set.seed(3)
  x <- .compute_compliance_comparison(data.frame(compliance_index = c(0, 0, 1)),
                                     data.frame(compliance_index = c(0, 1, 1)),
                                     "A", "B", n_boot = 1)
  expect_equal(x$ci_lo, x$ci_hi)
  expect_true(all(x$ci_lo <= x$ci_hi))
})

test_that("bootstrap helpers handle zero and insufficient observations and preserve explicit seed", {
  expect_equal(.boot_quantile_ci(c(.2, .4), n_boot = 0), c(NA_real_, NA_real_))
  expect_equal(.boot_diff_ci(5, c(1, 2), n_boot = 10), c(NA_real_, NA_real_))
  expect_equal(.boot_quantile_ci(c(.2, NA), n_boot = 10), c(NA_real_, NA_real_))
  expect_error(.boot_quantile_ci(c(1, 2), n_boot = -.5), "nonnegative integer")
  expect_error(.boot_diff_ci(1:3, 2:4, n_boot = Inf), "nonnegative integer")
  set.seed(9)
  rng <- .Random.seed
  a <- .boot_quantile_ci(1:8, n_boot = 30, seed = 5)
  expect_identical(.Random.seed, rng)
  expect_identical(a, .boot_quantile_ci(1:8, n_boot = 30, seed = 5))
  expect_identical(.Random.seed, rng)
})

test_that("compliance requires received service and valid elapsed times", {
  d <- data.frame(scenario = "A", time_to_first_service = c(10, 30, NA),
                  received_service = c(0, 1, 1))
  x <- compute_compliance_index(d, n_bootstrap = 0)
  expect_equal(x$n_in_window, 1)
  expect_equal(x$ci, 1 / 3)
  d$time_to_first_service[1] <- -1
  expect_error(compute_compliance_index(d), "nonnegative finite")
  d$time_to_first_service[1] <- -Inf
  expect_error(compute_compliance_index(d), "nonnegative finite")
  d$time_to_first_service[1] <- 0
  expect_equal(compute_compliance_index(d, window_min = 0, n_bootstrap = 0)$ci, 0)
  expect_error(compute_compliance_index(d, window_min = Inf), "finite nonnegative")
  expect_error(compute_compliance_index(d, n_bootstrap = 1.5), "nonnegative integer")
  d$received_service[1] <- 2
  expect_error(compute_compliance_index(d), "binary 0/1")
})

test_that("single and pooled KM curves have correct estimates without comparative p-values", {
  d <- survival_fixture()
  one <- km_estimate(d, scenarios = "A")
  expect_equal(one$tidy$estimate, c(.5, .5))
  expect_equal(one$params$n_obs, 2)
  expect_true(is.na(one$logrank$p_value))
  expect_true("strata" %in% names(one$tidy))
  expect_no_error(ggplot2::ggplot_build(plot_km(one)))
  pooled <- km_estimate(d, stratify_by = character())
  expect_equal(pooled$params$n_obs, 6)
  expect_true(is.na(pooled$logrank$p_value))
  no_events <- d
  no_events$reached_stage2 <- 0L
  expect_warning(k <- km_estimate(no_events), NA)
  expect_true(is.na(k$logrank$p_value))
  expect_equal(k$tidy$estimate, rep(1, 6))
})

test_that("survival rejects ambiguous event codes and unobserved follow-up", {
  d <- survival_fixture()
  d$time_to_stage2[2] <- NA
  expect_error(km_estimate(d), "no missing values")
  d <- survival_fixture()
  d$reached_stage2[2] <- 2L
  expect_error(km_estimate(d), "binary 0/1")
  d <- survival_fixture()
  d$time_to_stage2[2] <- -1
  expect_error(km_estimate(d), "nonnegative finite")
  d <- survival_fixture()
  d$scenario[2] <- NA
  expect_error(km_estimate(d), "missing or nonfinite")
})

test_that("KM bootstrap returns attributable pointwise bands and preserves RNG", {
  d <- survival_fixture()
  set.seed(71)
  rng <- .Random.seed
  k <- km_estimate(d, n_bootstrap = 30, seed = 9)
  expect_identical(.Random.seed, rng)
  expect_setequal(unique(k$boot_ci$strata), c("scenario=A", "scenario=B", "scenario=C"))
  expect_true(all(k$boot_ci$n_boot == 30))
  expect_true(all(k$boot_ci$conf.low <= k$boot_ci$conf.high))
  expect_true(all(k$boot_ci$conf.low >= 0 & k$boot_ci$conf.high <= 1))
  c_rows <- k$boot_ci[k$boot_ci$strata == "scenario=C", ]
  expect_equal(c_rows$time, c(0, 5, 6))
  expect_equal(c_rows$estimate, c(1, 1, 1))
  expect_equal(c_rows$conf.low, c(1, 1, 1))
  expect_equal(c_rows$conf.high, c(1, 1, 1))
  b_tail <- k$boot_ci[k$boot_ci$strata == "scenario=B" & k$boot_ci$time == 4, ]
  expect_equal(b_tail$estimate, 0)
  expect_equal(b_tail$conf.high, 0)
  expect_identical(k$boot_ci, km_estimate(d, n_bootstrap = 30, seed = 9)$boot_ci)
  single <- km_estimate(d[1, ], n_bootstrap = 5)
  expect_true(all(is.na(single$boot_ci$conf.low)))
  expect_true(all(single$boot_ci$n_boot == 0))
})

test_that("Cox model honors explicit adjustment and reference specification", {
  set.seed(123)
  d <- data.frame(scenario = rep(c("A", "B"), each = 40),
                  severity = runif(80), time_to_stage2 = rexp(80),
                  reached_stage2 = sample(0:1, 80, replace = TRUE))
  expect_error(cox_model(d, covariates = c("scenario", "severitty"),
                         reference_scenario = "A"), "Requested covariates")
  expect_error(cox_model(d, covariates = "scenario", reference_scenario = "missing"),
               "Reference scenario")
  expect_warning(cx <- cox_model(d, reference_scenario = "A"), "group")
  expect_equal(cx$params$covariates, c("scenario", "severity"))
  expect_equal(cx$params$n_obs, cx$fit$n)
  expect_equal(cx$params$reference_scenario, "A")
  d$severity[1] <- NA
  expect_error(cox_model(d, covariates = c("scenario", "severity"),
                         reference_scenario = "A"), "missing or nonfinite")
})

test_that("autonomy missing compliance is unknown, not an observed violation", {
  d <- data.frame(scenario = c("A", "B"), event_rate = c(.5, .2),
                  compliance_index = c(.9, NA_real_))
  al <- al_efficiency(d, al_scenarios = c("0" = "A", "1" = "B"), n_bootstrap = 0)
  expect_true(is.na(al$tradeoff_table$above_threshold[2]))
  expect_equal(nrow(al$compliance_violations), 0)
  expect_equal(al$optimal_al, 0L)
  expect_error(al_efficiency(d, al_scenarios = c("0" = "A"), reference_al = 4),
               "Reference AL")
  expect_error(al_efficiency(d, compliance_threshold = 1.2), "between 0 and 1")
})

test_that("all-missing elapsed times remain unconfirmed service", {
  d <- data.frame(scenario = "A", time_to_first_service = c(NA, NA))
  x <- compute_compliance_index(d, n_bootstrap = 0)
  expect_equal(x$n_total, 2)
  expect_equal(x$n_in_window, 0)
  expect_equal(x$ci, 0)
})

test_that("subgroup policy rates do not need a redundant status column", {
  d <- policy_fixture()
  d$replication <- rep(1:3, 2)
  entities <- data.frame(scenario = rep(c("A", "B"), each = 4),
                         replication = rep(c(1, 1, 2, 2), 2), group = "g",
                         event = c(1, 1, 0, 0, 0, 0, 0, 0))
  sim <- structure(list(summary = d, entities = entities), class = "dynasimR_data")
  p <- policy_effect(sim, "A", "B", n_bootstrap = 0)
  expect_equal(p$delta_event$median_pct_points[p$delta_event$group == "g"], 50)
  entities$status <- "TERMINATED"
  sim$entities <- entities
  expect_equal(policy_effect(sim, "A", "B", n_bootstrap = 0)$delta_event, p$delta_event)
})

test_that("KM zero-time and non-scenario strata retain meaningful labels", {
  d <- data.frame(group = c("x", "x"), time_to_stage2 = c(0, 0), reached_stage2 = c(1, 1))
  k <- km_estimate(d, stratify_by = "group", n_bootstrap = 5)
  expect_equal(k$tidy$strata, "group=x")
  expect_equal(k$boot_ci$strata, "group=x")
  expect_equal(k$boot_ci$estimate, 0)
  expect_equal(k$boot_ci$conf.high, 0)
  expect_true(is.na(k$params$n_scenarios))
})

test_that("autonomy cannot select an optimum without an observed event rate", {
  d <- data.frame(scenario = c("A", "B"), event_rate = c(.5, NA_real_),
                  compliance_index = c(.2, .9))
  al <- al_efficiency(d, al_scenarios = c("0" = "A", "1" = "B"), n_bootstrap = 0)
  expect_true(is.na(al$optimal_al))
})

test_that("autonomy reduction intervals describe the reference-minus-scenario effect", {
  d <- data.frame(scenario = rep(c("A", "B"), each = 2),
                  event_rate = c(.5, .5, .2, .2), compliance_index = .9)
  mapping <- c("0" = "A", "1" = "B")
  x <- al_efficiency(d, al_scenarios = mapping, n_bootstrap = 20)$tradeoff_table
  expect_equal(x$event_reduction_pct, c(0, 30))
  expect_equal(x$event_reduction_ci_lo, c(0, 30))
  expect_equal(x$event_reduction_ci_hi, c(0, 30))
  expect_equal(x$event_ci_lo, c(.5, .2))
  expect_equal(x$event_ci_hi, c(.5, .2))
  disabled <- al_efficiency(d, al_scenarios = mapping, n_bootstrap = 0)$tradeoff_table
  expect_true(all(is.na(disabled$event_reduction_ci_lo)))
  expect_true(all(is.na(disabled$event_reduction_ci_hi)))
  singleton <- al_efficiency(d[c(1, 3), ], al_scenarios = mapping,
                             n_bootstrap = 20)$tradeoff_table
  expect_true(all(is.na(singleton$event_reduction_ci_lo)))
  expect_true(all(is.na(singleton$event_reduction_ci_hi)))
  expect_equal(singleton$event_reduction_pct, c(0, 30))
  d$event_rate <- c(0, .4, .2, .2)
  set.seed(12)
  uncertain_reference <- al_efficiency(d, al_scenarios = mapping,
                                       n_bootstrap = 100)$tradeoff_table
  expect_equal(uncertain_reference$event_reduction_ci_lo[2], -20)
  expect_equal(uncertain_reference$event_reduction_ci_hi[2], 20)
  expect_equal(uncertain_reference$event_ci_lo[2], .2)
  expect_equal(uncertain_reference$event_ci_hi[2], .2)
})
