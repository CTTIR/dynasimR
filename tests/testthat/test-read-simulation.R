test_that("read_simulation loads bundled extdata with verbose msgs", {
  ext <- system.file("extdata", package = "dynasimR")
  expect_message(
    sim <- read_simulation(ext, verbose = TRUE),
    "Loading"
  )
  expect_s3_class(sim, "dynasimR_data")
  expect_true(sim$load_info$profile_type %in%
                c("Profile_A", "mixed"))
})

test_that("read_simulation warns on scenarios not found", {
  ext <- system.file("extdata", package = "dynasimR")
  expect_warning(
    sim <- read_simulation(ext, scenarios = c("A-S00", "NOPE"),
                           verbose = FALSE),
    "not found"
  )
  expect_true("A-S00" %in% sim$load_info$scenarios)
})

test_that("read_simulation aborts when no scenarios match", {
  ext <- system.file("extdata", package = "dynasimR")
  expect_error(
    suppressWarnings(
      read_simulation(ext, scenarios = "ZZZ", verbose = FALSE)),
    "No matching"
  )
})

test_that("read_simulation aborts on empty directory", {
  dir <- withr::local_tempdir()
  expect_error(read_simulation(dir, verbose = FALSE),
               "No simulation outputs")
})

test_that("read_simulation warns on scenario IDs without prefix", {
  dir <- withr::local_tempdir()
  readr::write_csv(
    tibble::tibble(scenario = "S00", replication = 1,
                   event_rate = 0.3, compliance_index = 0.8),
    file.path(dir, "S00_summary.csv")
  )
  expect_warning(
    read_simulation(dir, validate = FALSE, verbose = FALSE),
    "without prefix"
  )
})

test_that("print.dynasimR_data is invisible", {
  sim <- load_example_data()
  expect_invisible(print(sim))
})

test_that("load_example_data round-trips through read_simulation", {
  expect_s3_class(load_example_data(), "dynasimR_data")
})
