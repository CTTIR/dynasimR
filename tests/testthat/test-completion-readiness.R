completion_fixture <- function(classes = c("NONE", "FULL")) {
  d <- expand.grid(scenario = c("A", "B"), severity = 1:4,
                    completion_outcome = classes, stringsAsFactors = FALSE)
  d$completion_outcome <- factor(d$completion_outcome, levels = classes)
  d
}

test_that("completion coefficients retain binary and multinomial outcome labels", {
  skip_if_not_installed("nnet")
  binary <- compute_completion_analysis(completion_fixture())
  expect_identical(binary$tidy$class, "FULL")
  expect_equal(unlist(binary$tidy[-1], use.names = FALSE), rep(0, 3), tolerance = 1e-6)
  expect_identical(binary$params$reference_outcome, "NONE")
  expect_equal(binary$params$n_obs, 16)
  expect_equal(binary$proportions$prop, rep(.5, 4))
  multi <- compute_completion_analysis(completion_fixture(c("NONE", "PARTIAL", "FULL")))
  expect_identical(multi$tidy$class, c("PARTIAL", "FULL"))
  expect_equal(multi$proportions$prop, rep(1 / 3, 6))
})

test_that("completion models preserve requested covariates and reject incomplete samples", {
  d <- completion_fixture()
  expect_error(compute_completion_analysis(d, c("scenario", "severitty")),
               "Requested covariates")
  d$severity[1] <- NA
  expect_error(compute_completion_analysis(d), "missing or nonfinite")
  d <- completion_fixture()
  d$completion_outcome[1] <- NA
  expect_error(compute_completion_analysis(d), "missing or nonfinite")
  expect_error(compute_completion_analysis(d[1, ]), "missing or nonfinite")
})

test_that("completion models reject unidentifiable designs before fitting", {
  d <- completion_fixture()
  expect_error(compute_completion_analysis(d[d$completion_outcome == "FULL", ]),
               "at least two observed outcome classes")
  d$severity <- 1
  expect_error(compute_completion_analysis(d), "at least two observed values")
  d <- completion_fixture()
  d$duplicate <- d$severity
  expect_error(compute_completion_analysis(d, c("scenario", "severity", "duplicate")),
               "rank deficient")
  expect_error(compute_completion_analysis(d, "completion_outcome"),
               "outcome itself")
})

test_that("completion predictor names are data, not formula expressions", {
  skip_if_not_installed("nnet")
  d <- completion_fixture()
  names(d)[names(d) == "severity"] <- "risk + stop('must not execute')"
  fit <- compute_completion_analysis(d, c("scenario", "risk + stop('must not execute')"))
  expect_identical(fit$params$covariates, c("scenario", "risk + stop('must not execute')"))
  expect_identical(fit$tidy$class, "FULL")
  expect_equal(unlist(fit$tidy[-1], use.names = FALSE), rep(0, 3), tolerance = 1e-6)
})

test_that("group effects validate uncertainty settings even for singleton samples", {
  d <- data.frame(scenario = c("A", "B"), completion_rate = c(.75, .25), cost = c(8, 5))
  x <- group_effect(d, "A", "B", n_bootstrap = 0)
  expect_equal(x$delta_completion$delta_median, .5)
  expect_equal(x$delta_cost$delta_median, 3)
  expect_true(is.na(x$delta_completion$ci_lo))
  expect_true(is.na(x$delta_cost$ci_hi))
  expect_error(group_effect(d, "A", "B", alpha = 2), "alpha")
  expect_error(group_effect(d, "A", "B", n_bootstrap = -1), "nonnegative integer")
  expect_error(group_effect(d, "A", "B", n_bootstrap = 1.5), "nonnegative integer")
  d$completion_rate[1] <- 1.2
  expect_error(group_effect(d, "A", "B"), "between 0 and 1")
  d$completion_rate[1] <- NA
  expect_error(group_effect(d, "A", "B"), "at least one observed completion rate")
})

test_that("group effects report observed counts and omit invalid uncertainty", {
  d <- data.frame(scenario = c("A", "A", "B", "B"),
                  completion_rate = c(.75, NA, .25, .5), cost = c(8, NA, 5, 6))
  x <- group_effect(d, "A", "B", n_bootstrap = 20)
  expect_equal(x$completion$n, c(1, 2))
  expect_equal(x$delta_completion$delta_median, .375)
  expect_true(is.na(x$delta_completion$ci_lo))
  expect_true(is.na(x$delta_cost$ci_hi))
})

test_that("KM analytic confidence intervals can be disabled without breaking output", {
  d <- data.frame(scenario = rep(c("A", "B", "C"), each = 2),
                   time_to_stage2 = 1:6, reached_stage2 = c(1L, 0L, 1L, 1L, 0L, 0L))
  no_ci <- km_estimate(d, ci_method = "none", n_bootstrap = 5, seed = 7)
  ordinary <- km_estimate(d)
  expect_equal(no_ci$tidy$estimate, ordinary$tidy$estimate)
  expect_true(all(is.na(no_ci$tidy$conf.low)))
  expect_true(all(is.na(no_ci$tidy$conf.high)))
  expect_true(all(is.finite(no_ci$boot_ci$conf.low)))
  expect_equal(no_ci$params$ci_method, "none")
})
