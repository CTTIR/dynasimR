test_that("launch_app aborts when shiny is unavailable", {
  testthat::local_mocked_bindings(
    requireNamespace = function(package, ...) {
      if (identical(package, "shiny")) return(FALSE)
      TRUE
    },
    .package = "base"
  )
  expect_error(launch_app(), "shiny")
})

test_that("launch_app aborts on a non-existent data_dir", {
  skip_if_not_installed("shiny")
  expect_error(
    launch_app(data_dir = "definitely-not-a-real-dir-xyz"),
    "data_dir not found"
  )
})

test_that("check_app_dependencies returns a status tibble", {
  status <- check_app_dependencies()
  expect_s3_class(status, "tbl_df")
  expect_true(all(c("package", "installed", "version") %in%
                    names(status)))
  expect_type(status$installed, "logical")
})

test_that("check_app_dependencies reports missing packages", {
  testthat::local_mocked_bindings(
    requireNamespace = function(package, ...) FALSE,
    .package = "base"
  )
  status <- check_app_dependencies()
  expect_true(all(!status$installed))
  expect_true(all(is.na(status$version)))
})
