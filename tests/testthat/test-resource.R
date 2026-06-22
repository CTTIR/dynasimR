make_resource_summary <- function() {
  set.seed(21)
  tibble::tibble(
    scenario         = rep(c("A-S00", "A-S01", "A-S07"), each = 10),
    replication      = rep(1:10, 3),
    resource         = rep(c("none", "observation", "none"), each = 10),
    event_rate       = stats::runif(30, 0.1, 0.5),
    compliance_index = stats::runif(30, 0.6, 0.95)
  )
}

test_that("resource_comparison aggregates by resource config", {
  d <- make_resource_summary()
  out <- resource_comparison(d)
  expect_s3_class(out, "tbl_df")
  expect_true(all(c("resource", "n_scenarios", "n_reps",
                    "event_rate_median", "event_rate_q025",
                    "event_rate_q975") %in% names(out)))
  expect_equal(sort(out$resource), c("none", "observation"))
})

test_that("resource_comparison respects scenarios filter", {
  d <- make_resource_summary()
  out <- resource_comparison(d, scenarios = "A-S01")
  expect_equal(nrow(out), 1L)
  expect_equal(out$resource, "observation")
})

test_that("resource_comparison aborts without resource column", {
  d <- make_resource_summary()
  d$resource <- NULL
  expect_error(resource_comparison(d), "resource")
})

test_that("resource_comparison aborts when no metrics present", {
  d <- make_resource_summary()
  expect_error(
    resource_comparison(d, metrics = "nonexistent_metric"),
    "metrics"
  )
})

test_that("resource_comparison output is regression-stable", {
  d <- make_resource_summary()
  out <- resource_comparison(d, metrics = "event_rate")
  expect_snapshot_value(out, style = "json2")
})
