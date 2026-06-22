test_that("validate warns on missing summary columns (non-strict)", {
  x <- list(summary = tibble::tibble(foo = 1:3))
  expect_warning(validate_dynasimR_data(x), "summary missing")
  out <- suppressWarnings(validate_dynasimR_data(x))
  expect_true(!is.null(attr(out, "validation_issues")))
})

test_that("validate aborts on missing summary columns (strict)", {
  x <- list(summary = tibble::tibble(foo = 1:3))
  expect_error(validate_dynasimR_data(x, strict = TRUE),
               "summary missing")
})

test_that("validate warns on out-of-range event_rate", {
  x <- list(summary = tibble::tibble(
    scenario = "A", replication = 1, event_rate = 1.5))
  expect_warning(validate_dynasimR_data(x), "event_rate")
})

test_that("validate checks entity severity range and columns", {
  x <- list(
    summary  = tibble::tibble(scenario = "A", replication = 1),
    entities = tibble::tibble(scenario = "A", replication = 1,
                              severity = 2)
  )
  expect_warning(validate_dynasimR_data(x), "severity")
})

test_that("validate warns on entities missing required cols (strict)", {
  x <- list(
    summary  = tibble::tibble(scenario = "A", replication = 1),
    entities = tibble::tibble(foo = 1)
  )
  expect_error(validate_dynasimR_data(x, strict = TRUE),
               "entities missing")
})

test_that("validate warns on timeseries missing required cols", {
  x <- list(
    summary    = tibble::tibble(scenario = "A", replication = 1),
    entities   = tibble::tibble(scenario = "A", replication = 1),
    timeseries = tibble::tibble(foo = 1)
  )
  expect_warning(validate_dynasimR_data(x), "timeseries missing")
})

test_that("validate returns x invisibly with no issues", {
  x <- list(summary = tibble::tibble(scenario = "A", replication = 1))
  out <- validate_dynasimR_data(x)
  expect_null(attr(out, "validation_issues"))
})
