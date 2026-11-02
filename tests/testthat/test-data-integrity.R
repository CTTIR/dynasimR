write_import_fixture <- function(path, scenario = "A-S00", summary = NULL,
                                 entities = NULL, timeseries = NULL) {
  if (is.null(summary)) summary <- tibble::tibble(
    scenario = scenario, replication = 1, event_rate = 0.2)
  if (is.null(entities)) entities <- tibble::tibble(
    scenario = scenario, replication = 1, entity_id = 1)
  readr::write_csv(summary, file.path(path, paste0(scenario, "_summary.csv")))
  readr::write_csv(entities, file.path(path, paste0(scenario, "_entities.csv")))
  if (!is.null(timeseries)) readr::write_csv(
    timeseries, file.path(path, paste0(scenario, "_timeseries.csv")))
}

test_that("bundled metadata is available without changing source labels", {
  sim <- load_example_data()
  expect_true(all(c("resource", "al", "policy") %in% names(sim$summary)))
  expect_equal(unique(sim$summary$label[sim$summary$scenario == "A-S00"]),
               "Baseline")
  expect_equal(unique(sim$summary$resource[sim$summary$scenario == "A-S00"]),
               "none")
  expect_gt(nrow(resource_comparison(sim)), 0L)
})

test_that("external files never inherit example metadata by scenario ID", {
  path <- withr::local_tempdir()
  write_import_fixture(path)
  sim <- read_simulation(path, verbose = FALSE)
  expect_false(any(c("resource", "al", "policy", "label") %in%
                     names(sim$summary)))
  expect_equal(sim$metadata, tibble::tibble(id = "A-S00"))
})

test_that("caller metadata fills absent values without suffixes or data loss", {
  path <- withr::local_tempdir()
  write_import_fixture(path, summary = tibble::tibble(
    scenario = "A-S00", replication = 1, event_rate = 0.2,
    resource = "caller", al = NA_real_))
  readr::write_csv(tibble::tibble(id = "A-S00", resource = "caller",
                                 al = 5, policy = "custom"),
                   file.path(path, "scenario_metadata.csv"))
  sim <- read_simulation(path, verbose = FALSE)
  expect_equal(sim$summary$resource, "caller")
  expect_equal(sim$summary$al, 5)
  expect_equal(sim$entities$policy, "custom")
  expect_false(any(grepl("\\.[xy]$", names(sim$summary))))
  expect_equal(resource_comparison(sim, metrics = "event_rate")$resource,
               "caller")
  readr::write_csv(tibble::tibble(id = "A-S00", resource = "conflict"),
                   file.path(path, "scenario_metadata.csv"))
  expect_error(read_simulation(path, verbose = FALSE), "Metadata conflicts")
})

test_that("duplicate metadata keys cannot duplicate observations", {
  path <- withr::local_tempdir()
  write_import_fixture(path)
  readr::write_csv(tibble::tibble(id = c("A-S00", "A-S00"), al = c(1, 2)),
                   file.path(path, "scenario_metadata.csv"))
  expect_error(read_simulation(path, verbose = FALSE), "unique")
})

test_that("imports reject missing required files and inconsistent identities", {
  path <- withr::local_tempdir()
  write_import_fixture(path)
  unlink(file.path(path, "A-S00_entities.csv"))
  expect_error(read_simulation(path, verbose = FALSE), "Required simulation file")
  expect_equal(nrow(read_simulation(path, validate = FALSE,
                                    verbose = FALSE)$entities), 0L)
  write_import_fixture(path, summary = tibble::tibble(
    scenario = "A-S01", replication = 1, event_rate = 0.2))
  expect_error(read_simulation(path, verbose = FALSE), "must all equal")
  write_import_fixture(path, entities = tibble::tibble(
    scenario = "A-S00", replication = 2, entity_id = 1))
  expect_error(read_simulation(path, verbose = FALSE), "absent from summary")
})

test_that("mixed profile imports preserve per-scenario identity", {
  path <- withr::local_tempdir()
  write_import_fixture(path, timeseries = tibble::tibble(
    replication = 1, time_step = 1, count = 2))
  write_import_fixture(path, "B-S00", summary = tibble::tibble(
    replication = 1, progress_gain = 2), entities = tibble::tibble(
    replication = 1, progress_start = 1, progress_end = 3),
    timeseries = tibble::tibble(replication = 1, time_step = 1, progress = 2))
  sim <- read_simulation(path, verbose = FALSE)
  expect_equal(sim$load_info$profile_type, "mixed")
  for (nm in c("summary", "entities", "timeseries")) {
    expect_equal(sim[[nm]]$profile_type, c("Profile_A", "Profile_B"))
    expect_equal(sim[[nm]]$scenario, c("A-S00", "B-S00"))
  }
})

test_that("strict validation catches time-series schema and numeric defects", {
  expect_error(validate_dynasimR_data(
    list(timeseries = tibble::tibble(foo = 1)), strict = TRUE),
    "timeseries missing")
  expect_error(validate_dynasimR_data(list(summary = tibble::tibble(
    scenario = "A-S00", replication = 1, event_rate = "bad")), strict = TRUE),
    "must be numeric")
  expect_error(validate_dynasimR_data(list(summary = tibble::tibble(
    scenario = "A-S00", replication = NA_real_)), strict = TRUE),
    "nonmissing")
})

test_that("validation issues include rates and clear when repaired", {
  x <- list(summary = tibble::tibble(
    scenario = "A-S00", replication = 1, event_rate = 1.5))
  expect_warning(out <- validate_dynasimR_data(x), "outside")
  expect_match(attr(out, "validation_issues"), "event_rate")
  out$summary$event_rate <- 0.5
  expect_null(attr(validate_dynasimR_data(out), "validation_issues"))
  expect_error(validate_dynasimR_data(x, strict = TRUE), "outside")
})

test_that("stage completion fractions use observed indicators", {
  d <- tibble::tibble(scenario = "A-S00", time_to_stage1 = c(1, 2, NA_real_),
                      reached_stage1 = c(1, 0, NA_real_))
  out <- stage_throughput(d, "Stage1")
  expect_equal(out$completed_frac, 0.5)
  expect_equal(out$n, 3L)
  d$reached_stage1 <- c(1, 2, 0)
  expect_error(stage_throughput(d, "Stage1"), "binary")
})

test_that("SDI retains the balance threshold and handles zero demand", {
  d <- tibble::tibble(region = c("a", "b", "c", "d", "e"),
                      supply = c(1, 100, 0, 5, 0),
                      demand = c(1, 100, 0, 0, 1))
  out <- spatial_supply_demand(d)
  expect_equal(out$sdi_median[c(1, 2, 5)], c(1, 1, 0))
  expect_equal(out$undersupply[c(1, 2, 5)], c(FALSE, FALSE, TRUE))
  expect_true(all(is.na(out$sdi_median[3:4])))
  expect_true(all(is.na(out$undersupply[3:4])))
  expect_equal(out$n_zero_demand, c(0L, 0L, 1L, 1L, 0L))
  expect_equal(out$n_observed, c(1L, 1L, 0L, 0L, 1L))
  expect_equal(nrow(spatial_supply_demand(d[0, ])), 0L)
  d$supply[1] <- -1
  expect_error(spatial_supply_demand(d), "nonnegative")
  d$supply[1] <- Inf
  expect_error(spatial_supply_demand(d), "finite")
})

test_that("wait windows preserve units and the missing-value denominator", {
  d <- tibble::tibble(scenario = "B-S00", wait_days = c(0, 14, 15, NA_real_))
  out <- compute_wait_gap_index(d, n_bootstrap = 0)
  expect_equal(out$wgi, 0.5)
  expect_equal(out$n_in_window, 2L)
  expect_equal(out$n_total, 4L)
  d$wait_days_to_min <- d$wait_days * 1440
  d$wait_days <- NULL
  expect_equal(compute_wait_gap_index(d, n_bootstrap = 0)$wgi, 0.5)
  for (bad in c(-1, Inf, -Inf)) {
    d$wait_days_to_min[1] <- bad
    expect_error(compute_wait_gap_index(d, n_bootstrap = 0), "finite")
  }
  expect_error(compute_wait_gap_index(d, window_days = NA_real_), "window_days")
  expect_error(compute_wait_gap_index(d, n_bootstrap = 0.5), "integer")
})

test_that("screening handles constant or unobserved inputs explicitly", {
  d <- tibble::tibble(event_rate = seq(0.1, 0.5, 0.1), constant = 1)
  expect_warning(out <- morris_screening(d, inputs = "constant"), "constant input")
  expect_true(is.na(out$mu_star))
  expect_true(is.na(out$rank))
  expect_equal(out$status, "constant input")
  d$input <- 1:5
  d$event_rate <- 0.5
  expect_warning(out <- morris_screening(d, inputs = "input"), "constant outcome")
  expect_true(is.na(out$r2))
  d$input <- NA_real_
  expect_warning(out <- morris_screening(d, inputs = "input"), "insufficient")
  expect_equal(out$n_observed, 0L)
})

test_that("screening standardizes paired data and matches correlation", {
  d <- tibble::tibble(event_rate = c(0.2, 0.4, 0.3, 0.9, NA_real_),
                      input = c(1, 3, 2, 4, 1000))
  out <- morris_screening(d, inputs = "input")
  expected <- abs(stats::cor(d$input[1:4], d$event_rate[1:4]))
  expect_equal(out$mu_star, expected, tolerance = 1e-12)
  expect_equal(out$r2, expected^2, tolerance = 1e-12)
  expect_equal(out$n_observed, 4L)
  expect_equal(out$rank, 1L)
})

test_that("all absent tornado perturbations return a typed empty table", {
  d <- tibble::tibble(scenario = "A-S00", event_rate = 0.5)
  out <- tornado_data(d, baseline = "A-S00", perturbations = "absent")
  expect_equal(nrow(out), 0L)
  expect_equal(names(out), c("scenario", "delta", "lo", "hi"))
})

test_that("a valid scenario cannot mask another scenario's missing schema", {
  path <- withr::local_tempdir()
  write_import_fixture(path, timeseries = tibble::tibble(
    replication = 1, time_step = 1, count = 2))
  write_import_fixture(path, "A-S01", timeseries = tibble::tibble(
    replication = 1, count = 2))
  expect_error(read_simulation(path, verbose = FALSE), "timeseries missing: time_step")
})

test_that("all missing waits retain entities in the denominator", {
  d <- tibble::tibble(scenario = "B-S00", wait_days = c(NA, NA))
  out <- compute_wait_gap_index(d, n_bootstrap = 0)
  expect_equal(out$wgi, 0)
  expect_equal(out$n_total, 2L)
  expect_equal(out$n_in_window, 0L)
})

test_that("all missing numeric columns have defined descriptive results", {
  d <- tibble::tibble(region = "a", supply = NA, demand = NA)
  out <- spatial_supply_demand(d)
  expect_true(is.na(out$sdi_median))
  expect_equal(out$n_observed, 0L)
  expect_warning(out <- morris_screening(
    tibble::tibble(event_rate = NA, input = 1:3), inputs = "input"),
    "insufficient")
  expect_equal(out$n_observed, 0L)
})

test_that("numeric replication identifiers cannot be infinite", {
  path <- withr::local_tempdir()
  write_import_fixture(path, summary = tibble::tibble(
    scenario = "A-S00", replication = Inf, event_rate = 0.2))
  expect_error(read_simulation(path, verbose = FALSE), "finite when numeric")
})
