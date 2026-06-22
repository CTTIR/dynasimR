test_that("km_estimate aborts when no rows after filtering", {
  sim <- load_example_data()
  expect_error(km_estimate(sim, scenarios = "ZZZ"),
               "No entity rows")
})

test_that("km_estimate bootstrap CI path runs", {
  sim <- load_example_data()
  km <- km_estimate(sim, endpoint = "stage2",
                    scenarios = c("A-S00", "A-S01"),
                    n_bootstrap = 5, seed = 1)
  expect_false(is.null(km$boot_ci))
})

test_that("print.dynasimR_km is invisible", {
  sim <- load_example_data()
  km <- km_estimate(sim, endpoint = "stage2")
  expect_invisible(print(km))
})

test_that("plot.dynasimR_km dispatches to plot_km", {
  sim <- load_example_data()
  km <- km_estimate(sim, endpoint = "stage2")
  p <- plot(km)
  expect_s3_class(p, "ggplot")
})

test_that("cox_model aborts when no covariates present", {
  ent <- tibble::tibble(time_to_stage2 = 1:5, reached_stage2 = 1)
  expect_error(
    cox_model(ent, endpoint = "stage2",
              covariates = c("nope1", "nope2")),
    "covariates"
  )
})

test_that("print.dynasimR_cox is invisible", {
  sim <- load_example_data()
  cx <- cox_model(sim, endpoint = "stage2",
                  reference_scenario = "A-S00")
  expect_invisible(print(cx))
  expect_true("ph_test" %in% names(cx))
})

test_that("km_estimate stratify by scenario+group works", {
  sim <- load_example_data()
  km <- km_estimate(sim, endpoint = "stage2",
                    stratify_by = c("scenario", "group"))
  expect_s3_class(km, "dynasimR_km")
  expect_gt(length(unique(km$tidy$strata)), 1)
})
