make_profile_b <- function(with_cost = TRUE) {
  set.seed(51)
  n <- 25
  ent <- tibble::tibble(
    scenario           = rep(c("B-S00", "B-S19"), each = n),
    replication        = rep(1:n, 2),
    entity_id          = 1:(2 * n),
    cohort             = rep(c("A", "B"), length.out = 2 * n),
    progress_start     = stats::rnorm(2 * n, 60, 10),
    progress_end       = stats::rnorm(2 * n, 95, 8),
    wait_days          = stats::rgamma(2 * n, shape = 2, rate = 0.2),
    severity           = stats::runif(2 * n, 0.2, 0.8),
    completion_outcome = factor(rep(c("FULL", "PARTIAL", "NONE"),
                                    length.out = 2 * n))
  )
  summ <- tibble::tibble(
    scenario        = rep(c("B-S00", "B-S19"), each = n),
    replication     = rep(1:n, 2),
    completion_rate = stats::runif(2 * n, 0.4, 0.9)
  )
  if (with_cost) summ$cost <- stats::runif(2 * n, 1000, 5000)
  structure(
    list(summary = summ, entities = ent,
         timeseries = tibble::tibble(),
         metadata = tibble::tibble(id = unique(summ$scenario)),
         load_info = list(profile_type = "Profile_B",
                          scenarios = unique(summ$scenario))),
    class = c("dynasimR_data", "list")
  )
}

test_that("group_effect requires both scenarios", {
  sim <- make_profile_b()
  expect_error(group_effect(sim, group_a_scenario = "B-S00"))
})

test_that("group_effect aborts on unknown scenario", {
  sim <- make_profile_b()
  expect_error(
    group_effect(sim, "B-S00", "ZZZ", n_bootstrap = 20),
    "Scenario"
  )
})

test_that("group_effect with cost returns cost slots", {
  sim <- make_profile_b(with_cost = TRUE)
  ge <- group_effect(sim, "B-S00", "B-S19", n_bootstrap = 30)
  expect_s3_class(ge, "dynasimR_group_effect")
  expect_false(is.null(ge$cost))
  expect_false(is.null(ge$delta_cost))
})

test_that("group_effect without cost returns NULL cost slots", {
  sim <- make_profile_b(with_cost = FALSE)
  ge <- group_effect(sim, "B-S00", "B-S19", n_bootstrap = 30)
  expect_null(ge$cost)
  expect_null(ge$delta_cost)
})

test_that("compute_completion_analysis returns proportions and fit", {
  sim <- make_profile_b()
  res <- compute_completion_analysis(sim)
  expect_s3_class(res, "dynasimR_completion")
  expect_true("proportions" %in% names(res))
  expect_s3_class(res$proportions, "tbl_df")
})

test_that("compute_completion_analysis errors without outcome col", {
  sim <- make_profile_b()
  sim$entities$completion_outcome <- NULL
  expect_error(compute_completion_analysis(sim),
               "completion_outcome")
})

test_that("compute_completion_analysis errors without valid covariates", {
  sim <- make_profile_b()
  expect_error(
    compute_completion_analysis(sim, covariates = "nope"),
    "No valid covariates"
  )
})

test_that("compute_completion_analysis falls back without nnet", {
  sim <- make_profile_b()
  testthat::local_mocked_bindings(
    requireNamespace = function(package, ...) {
      if (identical(package, "nnet")) return(FALSE)
      TRUE
    },
    .package = "base"
  )
  expect_warning(
    res <- compute_completion_analysis(sim),
    "nnet"
  )
  expect_null(res$fit)
})

test_that("compute_wait_gap_index handles unstratified data", {
  sim <- make_profile_b()
  wgi <- compute_wait_gap_index(sim, by_scenario = FALSE,
                                by_cohort = FALSE, n_bootstrap = 20)
  expect_true("wgi" %in% names(wgi))
  expect_true("wgi_critical" %in% names(wgi))
})

test_that("compute_wait_gap_index normalises minutes column", {
  sim <- make_profile_b()
  sim$entities$wait_days <- NULL
  sim$entities$wait_days_to_min <- stats::runif(
    nrow(sim$entities), 0, 20000)
  wgi <- compute_wait_gap_index(sim, n_bootstrap = 0)
  expect_true(all(wgi$wgi >= 0 & wgi$wgi <= 1, na.rm = TRUE))
})

test_that("compute_wait_gap_index aborts without a wait column", {
  sim <- make_profile_b()
  sim$entities$wait_days <- NULL
  expect_error(compute_wait_gap_index(sim), "wait_days")
})

test_that("compute_wait_gap_index returns empty tibble on empty input", {
  expect_equal(nrow(compute_wait_gap_index(tibble::tibble())), 0L)
})

test_that("progress_trajectory aborts on empty input", {
  expect_error(progress_trajectory(tibble::tibble()), "No entity")
})

test_that("progress_trajectory longitudinal uses timeseries progress", {
  sim <- make_profile_b()
  sim$timeseries <- tibble::tibble(
    scenario  = rep(c("B-S00", "B-S19"), each = 10),
    replication = rep(1:10, 2),
    time_step = rep(1:10, 2),
    progress  = stats::runif(20, 50, 90)
  )
  pr <- progress_trajectory(sim, longitudinal = TRUE)
  expect_false(is.null(pr$longitudinal))
  expect_true("progress_median" %in% names(pr$longitudinal))
})

test_that("print.dynasimR_progress is invisible", {
  sim <- make_profile_b()
  pr <- progress_trajectory(sim)
  expect_invisible(print(pr))
})

test_that("spatial_supply_demand flags undersupply", {
  sim <- make_profile_b()
  sim$summary$supply <- 50
  sim$summary$demand <- 100
  sim$summary$region <- "RegA"
  sdi <- spatial_supply_demand(sim)
  expect_true(all(sdi$undersupply))
})

test_that("spatial_supply_demand aborts on missing columns", {
  expect_error(
    spatial_supply_demand(tibble::tibble(region = "A")),
    "missing"
  )
})
