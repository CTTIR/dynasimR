test_that("risk tables count entities before each event or censoring time", {
  d <- data.frame(scenario = "A", time_to_stage2 = 1:4,
                  reached_stage2 = c(1, 0, 1, 0))
  km <- km_estimate(d)
  risk <- .km_risk_table(km, 0:5)
  expect_equal(risk$n.risk, c(4, 4, 3, 2, 1, 0))
  expect_equal(unique(risk$strata), unique(km$tidy$strata))
  skip_if_not_installed("patchwork")
  p <- plot_km(km, show_risktable = TRUE)
  expect_s3_class(p, "patchwork")
  expect_warning(patchwork::patchworkGrob(p), NA)
})

test_that("survival plots retain time zero and depleted endpoints without fake CIs", {
  d <- data.frame(scenario = "A", time_to_stage2 = 1:3,
                  reached_stage2 = 1)
  km <- km_estimate(d)
  p <- plot_km(km)
  curve <- ggplot2::ggplot_build(p)$data[[1]]
  expect_equal(curve$x, 0:3)
  expect_equal(curve$y, c(1, 2/3, 1/3, 0))
  expect_warning(ggplot2::ggplotGrob(p), NA)
  expect_false(grepl("p NA", p$labels$caption, fixed = TRUE))
})

test_that("risk tables preserve distinct strata and censoring", {
  d <- data.frame(scenario = rep(c("A", "B"), each = 3),
                  time_to_stage2 = c(1, 2, 4, 2, 3, 4),
                  reached_stage2 = c(1, 0, 1, 0, 0, 0))
  km <- km_estimate(d)
  risk <- .km_risk_table(km, c(0, 3, 5))
  expect_equal(risk$n.risk, c(3, 1, 0, 3, 2, 0))
  expect_setequal(unique(risk$strata), unique(km$tidy$strata))
})

test_that("zero-followup strata remain visible without a one-point step warning", {
  d <- data.frame(scenario = "A", time_to_stage2 = 0, reached_stage2 = 0)
  p <- plot_km(km_estimate(d))
  expect_message(ggplot2::ggplotGrob(p), NA)
  points <- ggplot2::ggplot_build(p)$data[[2]]
  expect_equal(points$x, 0)
  expect_equal(points$y, 1)
})

test_that("autonomy plots label the actual reference and draw reduction bounds", {
  d <- data.frame(scenario = rep(c("A", "B"), each = 3),
                  event_rate = c(.2, .2, .2, .4, .4, .4), compliance_index = .9)
  al <- al_efficiency(d, al_scenarios = c("0" = "A", "1" = "B"),
                      reference_al = 1, n_bootstrap = 20)
  p <- plot_al_tradeoff(al)
  expect_match(p$labels$x, "AL1", fixed = TRUE)
  interval <- ggplot2::ggplot_build(p)$data[[4]]
  expect_equal(interval$xmin, c(20, 0))
  expect_equal(interval$xmax, c(20, 0))
})

test_that("progress range can be hidden in the summary view", {
  pr <- progress_trajectory(data.frame(scenario = "B", progress_start = 0,
                                       progress_end = c(1, 2, 10)))
  hidden <- ggplot2::ggplot_build(plot_progress_curves(pr, show_ci = FALSE))
  shown <- ggplot2::ggplot_build(plot_progress_curves(pr, show_ci = TRUE))
  expect_length(hidden$data, 1)
  expect_equal(shown$data[[2]]$ymin, 1.05)
  expect_equal(shown$data[[2]]$ymax, 9.6)
})
