app_module <- function(name) {
  env <- new.env(parent = asNamespace("shiny"))
  sys.source(system.file("app", "modules", paste0(name, ".R"),
                          package = "dynasimR"), env)
  env
}

test_that("dashboard startup resolves paths and restores caller options", {
  for (package in dynasimR:::.app_dependencies()) skip_if_not_installed(package)
  withr::local_options(list(dynasimR.data_dir = "caller-option"))
  testthat::local_mocked_bindings(runApp = function(appDir, ...) {
    path <- getOption("dynasimR.data_dir")
    expect_true(dir.exists(path))
    withr::local_dir(appDir)
    expect_true(dir.exists(path))
    data <- read_simulation(path, verbose = FALSE)
    expect_gt(nrow(data$entities), 0L)
    stop("test app closed")
  }, .package = "shiny")
  example <- system.file("extdata", package = "dynasimR")
  withr::local_dir(dirname(example))
  expect_error(launch_app("extdata", launch.browser = FALSE), "test app closed")
  expect_identical(getOption("dynasimR.data_dir"), "caller-option")
})

test_that("dashboard preflight identifies a missing required dependency", {
  testthat::local_mocked_bindings(
    requireNamespace = function(package, ...) package != "DT",
    .package = "base"
  )
  expect_error(launch_app(), "DT")
})

test_that("survival selectors use identical scenario sets for KM and Cox", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("shinyWidgets")
  env <- app_module("mod_survival")
  sim <- load_example_data()
  shiny::testServer(env$mod_survival_server, args = list(sim_data = sim), {
    session$setInputs(scenarios = c("A-S07", "A-S08"), endpoint = "stage2",
      stratify_group = FALSE, show_ci = FALSE, show_pval = TRUE)
    expect_equal(km_result()$params$n_scenarios, 2)
    expect_identical(cox_result()$forest_data$term, "A-S08")
    expect_equal(cox_result()$fit$n, 8000)
    session$setInputs(scenarios = "A-S07")
    expect_equal(km_result()$params$n_scenarios, 1)
    expect_null(cox_result())
  })
})

test_that("policy output renders user-controlled identifiers as text", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("shinyWidgets")
  skip_if_not_installed("DT")
  env <- app_module("mod_policy")
  sim <- load_example_data()
  id <- "<img src=x onerror=window.dynasimExecuted=1>"
  for (name in names(sim)) {
    if (is.data.frame(sim[[name]]) && "scenario" %in% names(sim[[name]]))
      sim[[name]]$scenario[sim[[name]]$scenario == "A-S08"] <- id
  }
  shiny::testServer(env$mod_policy_server, args = list(sim_data = sim), {
    session$setInputs(policy_a = "<img src=x onerror=window.dynasimExecuted=1>",
                      policy_b = "A-S07", alpha = .05)
    html <- output$narrative$html
    expect_match(html, "&lt;img", fixed = TRUE)
    expect_false(grepl("<img", html, fixed = TRUE))
  })
})

test_that("the export module honours selected format on extensionless paths", {
  skip_if_not_installed("shiny")
  env <- app_module("mod_export")
  output <- new.env()
  env$moduleServer <- function(id, module) module(
    list(export_format = "png", export_width = 80, export_height = 60),
    output, list())
  env$downloadHandler <- function(filename, content, ...) content
  env$mod_export_server("export", load_example_data())
  path <- withr::local_tempfile()
  output$dl_figure_km(path)
  expect_identical(readBin(path, "raw", n = 8),
    as.raw(c(137, 80, 78, 71, 13, 10, 26, 10)))
})

test_that("dashboard profile routing refuses mixed data", {
  expect_identical(dynasimR:::.dashboard_profile(list(
    load_info = list(profile_type = "Profile_B"))), "Profile_B")
  expect_error(dynasimR:::.dashboard_profile(list(
    load_info = list(profile_type = "mixed"))), "cannot combine")
})

test_that("Profile B table export retains progress units and completion fractions", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("xtable")
  env <- app_module("mod_export")
  sim <- list(summary = data.frame(scenario = rep(c("B-S00", "B-S19"), each = 4),
    replication = rep(1:4, 2), progress_gain = 1:8,
    completion_rate = rep(c(.25, .5, .75, 1), 2)),
    load_info = list(profile_type = "Profile_B"))
  output <- new.env()
  env$moduleServer <- function(id, module) module(list(), output, list())
  env$downloadHandler <- function(filename, content, ...) content
  env$mod_export_server("export", sim)
  path <- withr::local_tempfile(fileext = ".tex")
  output$dl_latex_outcomes(path)
  tex <- paste(readLines(path), collapse = "\n")
  expect_match(tex, "progress\\_gain", fixed = TRUE)
  expect_match(tex, "completion\\_rate", fixed = TRUE)
  expect_match(tex, "2.500", fixed = TRUE)
  expect_match(tex, "0.625", fixed = TRUE)
  expect_false(exists("dl_figure_km", envir = output, inherits = FALSE))
  ui <- as.character(env$mod_export_ui("export", profile_b = TRUE))
  expect_match(ui, "not available for Profile B", fixed = TRUE)
  expect_false(grepl("Download figure", ui, fixed = TRUE))
})
