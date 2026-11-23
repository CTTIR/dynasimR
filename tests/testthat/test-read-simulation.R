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
  readr::write_csv(
    tibble::tibble(scenario = "S00", replication = 1, entity_id = 1),
    file.path(dir, "S00_entities.csv")
  )
  expect_warning(
    read_simulation(dir, verbose = FALSE),
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

test_that("small simulation files are read on one thread", {
  small <- withr::local_tempfile(fileext = ".csv")
  writeLines(c("a,b", "1,2"), small)
  expect_identical(.csv_threads(small), 1L)
  withr::local_options(readr.num_threads = 3L)
  expect_equal(.csv_threads(small, small = 1), 3)

  threads <- integer()
  real <- readr::read_csv
  local_mocked_bindings(read_csv = function(file, ..., num_threads) {
    threads <<- c(threads, num_threads)
    real(file, ..., num_threads = num_threads)
  }, .package = "readr")
  read_simulation(system.file("extdata", package = "dynasimR"),
                  verbose = FALSE)
  expect_gt(length(threads), 0L)
  expect_true(all(threads == 1L))
})
