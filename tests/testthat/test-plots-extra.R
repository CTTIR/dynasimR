test_that("plot_timeline renders from timeseries", {
  sim <- load_example_data()
  p <- plot_timeline(sim, metric = "active_entities")
  expect_s3_class(p, "ggplot")
})

test_that("plot_timeline filters scenarios and groups", {
  sim <- load_example_data()
  p <- plot_timeline(sim, metric = "capacity_utilisation",
                     scenarios = c("A-S00", "A-S01"),
                     group = "time_unit")
  expect_s3_class(p, "ggplot")
})

test_that("plot_timeline aborts on empty timeseries", {
  expect_error(plot_timeline(tibble::tibble(), metric = "x"),
               "empty")
})

test_that("plot_timeline aborts on missing metric", {
  sim <- load_example_data()
  expect_error(plot_timeline(sim, metric = "nonexistent"),
               "not in timeseries")
})

test_that("plot_map status colouring works", {
  sim <- load_example_data()
  p <- plot_map(sim, color_by = "status", scenarios = "A-S00")
  expect_s3_class(p, "ggplot")
})

test_that("plot_map aborts without x/y", {
  ent <- tibble::tibble(scenario = "A-S00", group = "A")
  expect_error(plot_map(ent), "x.*y")
})

test_that("plot_scenario_heatmap aborts when no metrics present", {
  sim <- load_example_data()
  expect_error(
    plot_scenario_heatmap(sim, metrics = "nope"),
    "metrics"
  )
})

test_that("plot_radar renders with two metrics", {
  sim <- load_example_data()
  p <- plot_radar(sim, scenarios = c("A-S00", "A-S01"),
                  metrics = c("event_rate", "compliance_index"))
  expect_s3_class(p, "ggplot")
})

test_that("plot_radar needs at least two metrics", {
  sim <- load_example_data()
  expect_error(
    plot_radar(sim, scenarios = "A-S00",
               metrics = c("event_rate")),
    "at least 2"
  )
})

test_that("plot_km handles empty tidy gracefully", {
  km <- structure(
    list(tidy = tibble::tibble(), logrank = NULL, params = list()),
    class = c("dynasimR_km", "list")
  )
  p <- plot_km(km)
  expect_s3_class(p, "ggplot")
})

test_that("plot_km rejects wrong class", {
  expect_error(plot_km(list()), "dynasimR_km")
})

test_that("plot_km respects options (policy colour, xlim, no ci)", {
  sim <- load_example_data()
  km <- km_estimate(sim, endpoint = "stage2")
  p <- plot_km(km, color_by = "policy", show_ci = FALSE,
               show_median = FALSE, show_pval = FALSE,
               xlim = c(0, 10))
  expect_s3_class(p, "ggplot")
})

test_that("plot_forest rejects wrong class and empty forest", {
  expect_error(plot_forest(list()), "dynasimR_cox")
  cx <- structure(
    list(forest_data = tibble::tibble(), params = list()),
    class = c("dynasimR_cox", "list")
  )
  expect_error(plot_forest(cx), "No scenario terms")
})

test_that("plot_al_tradeoff toggles labelling and optimal highlight", {
  sim <- load_example_data()
  al <- al_efficiency(sim,
    al_scenarios = c("0" = "A-S00", "1" = "A-S01"),
    n_bootstrap = 50)
  p <- plot_al_tradeoff(al, label_points = FALSE,
                        highlight_optimal = FALSE)
  expect_s3_class(p, "ggplot")
})

test_that("plot_al_tradeoff rejects wrong class", {
  expect_error(plot_al_tradeoff(list()), "dynasimR_al_analysis")
})

test_that("plot_policy rejects wrong class", {
  expect_error(plot_policy(list()), "dynasimR_policy")
})
