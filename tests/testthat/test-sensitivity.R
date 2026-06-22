make_sens_summary <- function() {
  set.seed(31)
  n <- 60
  x1 <- stats::runif(n)
  x2 <- stats::runif(n)
  tibble::tibble(
    scenario   = rep(c("A-S00", "A-S01", "A-S07"), length.out = n),
    event_rate = 0.5 * x1 + 0.1 * x2 + stats::rnorm(n, 0, 0.02),
    input_a    = x1,
    input_b    = x2
  )
}

test_that("morris_screening ranks inputs by influence", {
  d <- make_sens_summary()
  out <- morris_screening(d, outcome = "event_rate",
                          inputs = c("input_a", "input_b"))
  expect_s3_class(out, "tbl_df")
  expect_true(all(c("input", "mu_star", "sigma", "r2",
                    "rank") %in% names(out)))
  # input_a has the larger coefficient -> rank 1
  expect_equal(out$input[out$rank == 1], "input_a")
})

test_that("morris_screening aborts on missing columns", {
  d <- make_sens_summary()
  expect_error(
    morris_screening(d, outcome = "event_rate",
                     inputs = c("does_not_exist")),
    "missing"
  )
})

test_that("morris_screening accepts a dynasimR_data object", {
  sim <- load_example_data()
  out <- morris_screening(sim, outcome = "event_rate",
                          inputs = "compliance_index")
  expect_equal(nrow(out), 1L)
})

test_that("tornado_data computes deltas vs baseline", {
  d <- make_sens_summary()
  out <- tornado_data(d, baseline = "A-S00",
                      perturbations = c("A-S01", "A-S07"))
  expect_true(all(c("scenario", "delta", "lo", "hi") %in% names(out)))
  expect_equal(nrow(out), 2L)
  # sorted by absolute delta descending
  expect_true(abs(out$delta[1]) >= abs(out$delta[2]))
})

test_that("tornado_data aborts on unknown baseline", {
  d <- make_sens_summary()
  expect_error(
    tornado_data(d, baseline = "ZZZ", perturbations = "A-S01"),
    "Baseline"
  )
})

test_that("tornado_data skips perturbations not in data", {
  d <- make_sens_summary()
  out <- tornado_data(d, baseline = "A-S00",
                      perturbations = c("A-S01", "MISSING"))
  expect_equal(nrow(out), 1L)
})
