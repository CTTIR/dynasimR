cost_outcome_fixture <- function() {
  tibble::tibble(scenario = rep(c("reference", "candidate", "zero"), each = 3),
                 completion_rate = c(.25, .5, .75, .25, .75, 1, .5, .5, .5),
                 cost = c(10, 20, 30, 15, 25, 30, 30, 40, 50))
}

test_that("cost plane preserves exact median differences and undefined ratios", {
  d <- cost_outcome_fixture()
  p <- plot_cost_effectiveness(d, "reference", c("candidate", "zero"))
  expect_equal(p$data$delta_effect, c(.25, 0))
  expect_equal(p$data$delta_cost, c(5, 20))
  expect_equal(p$data$icer[1], 20, tolerance = 1e-12)
  expect_true(is.na(p$data$icer[2]))
  expect_equal(p$data$n_observed, c(3L, 3L))
  expect_match(p$labels$subtitle, "fixed reference medians")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("net-benefit fractions retain fixed-reference empirical meaning", {
  p <- plot_cost_effectiveness(cost_outcome_fixture(), "reference", "candidate",
                               wtp = c(0, 20, 40), show_ceac = TRUE)
  expect_equal(p$data$prob_ce, c(1/3, 0, 2/3))
  expect_equal(p$data$n_observed, rep(3L, 3))
  expect_match(p$labels$y, "Observed fraction")
  expect_match(p$labels$caption, "Reference uncertainty is not estimated")
  expect_false(grepl("Probability|acceptability", p$labels$y))
  expect_no_error(ggplot2::ggplot_build(p))
  one <- plot_cost_effectiveness(cost_outcome_fixture(), "reference", "candidate",
                                 wtp = 20, show_ceac = TRUE)
  expect_s3_class(one$layers[[1]]$geom, "GeomPoint")
  expect_no_error(ggplot2::ggplotGrob(one))
})

test_that("every requested cost scenario must exist", {
  d <- cost_outcome_fixture()
  expect_error(plot_cost_effectiveness(d, "reference", c("candidate", "missing")),
               "Scenarios not in data")
  expect_error(plot_cost_effectiveness(d, "reference", character()), "nonempty")
  expect_error(plot_cost_effectiveness(d, "missing", "candidate"), "Reference")
})

test_that("incomplete and nonfinite cost-outcome pairs fail explicitly", {
  for (bad in c(NA_real_, Inf, -Inf)) {
    d <- cost_outcome_fixture()
    d$cost[4] <- bad
    expect_error(plot_cost_effectiveness(d, "reference", "candidate"),
                 "finite observed cost-outcome pairs")
    d <- cost_outcome_fixture()
    d$completion_rate[1] <- bad
    expect_error(plot_cost_effectiveness(d, "reference", "candidate", show_ceac = TRUE),
                 "finite observed cost-outcome pairs")
  }
})

test_that("WTP thresholds must be finite, nonnegative and nonempty", {
  d <- cost_outcome_fixture()
  for (wtp in list(-1, NA_real_, Inf, numeric(), "20"))
    expect_error(plot_cost_effectiveness(d, "reference", "candidate",
                                        wtp = wtp, show_ceac = TRUE), "wtp")
})
