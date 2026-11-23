# Regression tests for defects found by rendering every plot.

test_that("p-values are printed with their relation", {
  expect_equal(dynasimR:::.format_p_text(0.0001), "p < 0.001")
  expect_equal(dynasimR:::.format_p_text(0.005), "p = 0.005")
  expect_equal(dynasimR:::.format_p_text(0.04, "Log-rank p"),
               "Log-rank p = 0.040")
})

test_that("plot_km states the log-rank p-value and shortens legend keys", {
  sim <- load_example_data()
  km <- km_estimate(sim, endpoint = "stage2", stratify_by = "scenario")
  p <- plot_km(km)
  expect_match(p$labels$caption, "log-rank p (=|<) ")
  built <- ggplot2::ggplot_build(p)
  keys <- built$plot$scales$get_scales("colour")$get_labels()
  expect_setequal(keys, unique(sim$entities$scenario))
  expect_identical(p$labels$colour, "scenario")
  # The fitted strata labels are data and stay as survfit() wrote them.
  expect_true(all(grepl("^scenario=", km$tidy$strata)))

  km2 <- km_estimate(sim, endpoint = "stage2",
                     stratify_by = c("scenario", "group"))
  keys2 <- ggplot2::ggplot_build(plot_km(km2))$plot$scales$
    get_scales("colour")$get_labels()
  expect_true(all(grepl("scenario=", keys2, fixed = TRUE)))
})

test_that("the policy narrative states the adjusted p-value relation", {
  sim <- load_example_data()
  pol <- policy_effect(sim, policy_a_scenario = "A-S08",
                       policy_b_scenario = "A-S07", n_bootstrap = 50)
  expect_match(pol$narrative, "adjusted p (=|<) ")
})

test_that("plot_radar joins evenly spaced spokes with straight lines", {
  sim <- load_example_data()
  metrics <- c("event_rate", "compliance_index",
               "median_time_to_first_service")
  p <- plot_radar(sim, scenarios = c("A-S00", "A-S08"), metrics = metrics,
                  rescale = TRUE)
  expect_s3_class(p, "ggplot")
  expect_s3_class(p$coordinates, "CoordPolar")
  expect_true(p$coordinates$is_linear())
  expect_identical(p$coordinates$clip, "off")
  built <- ggplot2::ggplot_build(p)
  outline <- built$data[[2]]
  expect_setequal(outline$x, 1:3)
  expect_true(all(outline$y >= 0 & outline$y <= 1))
  expect_identical(p$labels$colour, "Scenario")
  # Spoke labels are anchored at the rim and point away from the centre.
  spokes <- built$data[[4]]
  expect_identical(trimws(spokes$label), metrics)
  expect_true(all(spokes$y > max(outline$y)))
  expect_identical(spokes$hjust[c(1, 2)], c(0, 1))
  # Renders without error on a real device.
  path <- tempfile(fileext = ".png")
  on.exit(unlink(path), add = TRUE)
  grDevices::png(path)
  print(p)
  grDevices::dev.off()
  expect_gt(file.info(path)$size, 0)
})

test_that("plot_radar keeps raw medians by default and validates input", {
  sim <- load_example_data()
  p <- plot_radar(sim, scenarios = c("A-S00", "A-S08"))
  raw <- ggplot2::ggplot_build(p)$data[[2]]
  expected <- tapply(sim$summary$event_rate, sim$summary$scenario,
                     stats::median)[c("A-S00", "A-S08")]
  expect_equal(sort(raw$y[raw$x == 1]), sort(as.numeric(expected)))
  expect_error(plot_radar(sim, scenarios = "no-such-scenario"),
               "None of the requested scenarios")
  expect_error(plot_radar(sim, scenarios = "A-S00", rescale = NA),
               "rescale")
  expect_equal(dynasimR:::.rescale_unit(c(2, 4, 6)), c(0, 0.5, 1))
  expect_equal(dynasimR:::.rescale_unit(c(3, 3, NA)), c(0.5, 0.5, NA))
})

test_that("heatmap labels contrast with their tiles", {
  sim <- load_example_data()
  p <- plot_scenario_heatmap(sim)
  built <- ggplot2::ggplot_build(p)
  light <- built$data[[2]]
  dark <- built$data[[3]]
  expect_true(all(light$colour == "#1A1A1A"))
  expect_true(all(dark$colour == "white"))
  expect_equal(nrow(light) + nrow(dark), nrow(built$data[[1]]))
  medians <- tapply(sim$summary$compliance_index, sim$summary$scenario,
                    stats::median)
  top <- formatC(max(medians), digits = 2, format = "f")
  expect_true(top %in% dark$label)
  expect_equal(dynasimR:::.contrast_position(c(1, 2, 3, NA)),
               c(0, 0.5, 1, 0))
  expect_equal(dynasimR:::.contrast_position(c(2, 2)), c(0, 0))
})

test_that("SDI tile labels contrast with their tiles", {
  sdi <- tibble::tibble(
    region = c("Low", "Balanced", "High"),
    sdi_median = c(0.5, 1.01, 1.5), x = 1:3, y = c(1, 1, 1)
  )
  built <- ggplot2::ggplot_build(plot_sdi_map(sdi))
  expect_identical(built$data[[2]]$label, "Balanced")
  expect_true(all(built$data[[2]]$colour == "#1A1A1A"))
  expect_setequal(built$data[[3]]$label, c("Low", "High"))
  expect_true(all(built$data[[3]]$colour == "white"))
  # Under- and oversupply use red and blue, not red and green.
  fills <- built$data[[1]]$fill
  rgb_high <- grDevices::col2rgb(fills[sdi$region == "High"])
  expect_gt(rgb_high["blue", 1], rgb_high["green", 1])
  expect_error(plot_sdi_map(sdi[c("x", "y")]), "region")
})

test_that("AL trade-off labels are drawn above the optimum ring", {
  sim <- load_example_data()
  al <- al_efficiency(sim, al_scenarios = c("0" = "A-S00", "1" = "A-S01"),
                      n_bootstrap = 50)
  p <- plot_al_tradeoff(al)
  geoms <- vapply(p$layers, function(l) class(l$geom)[1], character(1))
  expect_identical(unname(geoms[length(geoms)]), "GeomText")
  expect_match(p$labels$caption, "Optimum \\(circle\\): AL1\\.")

  none <- al_efficiency(sim, al_scenarios = c("0" = "A-S00"),
                        n_bootstrap = 0)
  expect_true(is.na(none$optimal_al))
  caption <- plot_al_tradeoff(none)$labels$caption
  expect_no_match(caption, "ALNA")
  expect_match(caption, "No autonomy level meets the threshold")
})

test_that("cost-outcome labels do not sit on their points", {
  runs <- data.frame(
    scenario = rep(c("B-S00", "B-S01"), each = 4),
    completion_rate = c(0.5, 0.55, 0.6, 0.65, 0.6, 0.65, 0.7, 0.75),
    cost = c(900, 950, 1000, 1050, 1000, 1100, 1200, 1300)
  )
  p <- plot_cost_effectiveness(runs, reference = "B-S00",
                               scenarios = "B-S01")
  text <- Filter(function(l) inherits(l$geom, "GeomText"), p$layers)[[1]]
  expect_lt(text$aes_params$vjust, 0)
  expect_identical(
    ggplot2::ggplot_build(p)$plot$scales$get_scales("colour")$name,
    "Scenario"
  )
})

test_that("status maps and timelines label their legends", {
  sim <- load_example_data()
  p <- plot_map(sim, color_by = "status", scenarios = "A-S00")
  expect_s3_class(ggplot2::ggplot_build(p)$plot, "ggplot")
  tl <- plot_timeline(sim, metric = "capacity_utilisation")
  expect_identical(tl$labels$colour, "Scenario")
  expect_match(tl$labels$caption, "median")
})

test_that("print.dynasimR_policy wraps the narrative to the console width", {
  sim <- load_example_data()
  pol <- policy_effect(sim, policy_a_scenario = "A-S08",
                       policy_b_scenario = "A-S07", n_bootstrap = 50)
  withr::local_options(width = 60)
  lines <- utils::capture.output(suppressMessages(print(pol)), type = "output")
  expect_true(all(nchar(lines) <= 60))
  narrative <- paste(lines[seq(grep("^The policy", lines)[1], length(lines))],
                     collapse = " ")
  expect_identical(gsub("\\s+", " ", trimws(narrative)),
                   gsub("\\s+", " ", trimws(pol$narrative)))
})

test_that("entity maps title their legend", {
  sim <- load_example_data()
  expect_identical(plot_map(sim, scenarios = "A-S00")$labels$colour, "Group")
  expect_identical(
    plot_map(sim, color_by = "status", scenarios = "A-S00")$labels$colour,
    "Status"
  )
})

test_that("plot_policy states what its points and whiskers show", {
  sim <- load_example_data()
  pol <- policy_effect(sim, policy_a_scenario = "A-S08",
                       policy_b_scenario = "A-S07", n_bootstrap = 50,
                       alpha = 0.1, seed = 1)
  p <- plot_policy(pol)
  expect_identical(p$labels$y, "Group")
  expect_match(p$labels$caption, "90% percentile bootstrap interval",
               fixed = TRUE)
  pol0 <- policy_effect(sim, policy_a_scenario = "A-S08",
                        policy_b_scenario = "A-S07", n_bootstrap = 0)
  expect_identical(plot_policy(pol0)$labels$caption,
                   "Point: difference of medians.")
})

test_that("progress plots explain their bars, bands and whiskers", {
  set.seed(1)
  entities <- data.frame(
    scenario       = rep(c("B-S00", "B-S01"), each = 20),
    progress_start = stats::runif(40, 40, 60),
    progress_end   = stats::runif(40, 60, 90)
  )
  pr <- progress_trajectory(entities)
  expect_match(plot_progress_curves(pr)$labels$caption, "whiskers")
  expect_null(plot_progress_curves(pr, show_ci = FALSE)$labels$caption)

  long <- tibble::tibble(
    scenario = rep(c("B-S00", "B-S01"), each = 3), time_step = rep(1:3, 2),
    progress_median = 1:6, progress_q025 = 0:5, progress_q975 = 2:7
  )
  pr_long <- structure(
    list(summary = tibble::tibble(), longitudinal = long, params = list()),
    class = c("dynasimR_progress", "list")
  )
  shown <- plot_progress_curves(pr_long)
  expect_match(shown$labels$caption, "band")
  expect_identical(shown$labels$colour, "Scenario")
  expect_no_match(plot_progress_curves(pr_long, show_ci = FALSE)$labels$caption,
                  "band")
})

test_that("plot_radar leaves the innermost ring unlabelled", {
  sim <- load_example_data()
  raw <- ggplot2::ggplot_build(plot_radar(sim, c("A-S00", "A-S08")))
  expect_false(any(as.numeric(raw$data[[1]]$label) == 0))
  scaled <- ggplot2::ggplot_build(plot_radar(
    sim, c("A-S00", "A-S08"),
    metrics = c("event_rate", "compliance_index",
                "median_time_to_first_service"),
    rescale = TRUE
  ))
  expect_false(any(as.numeric(scaled$data[[1]]$label) <= 0))
  expect_true(any(as.numeric(scaled$data[[1]]$label) == 1))
})

test_that("AL labels below the threshold sit underneath their points", {
  sim <- load_example_data()
  al <- al_efficiency(sim, al_scenarios = c("0" = "A-S00", "1" = "A-S01"),
                      n_bootstrap = 0)
  p <- plot_al_tradeoff(al)
  labels <- ggplot2::ggplot_build(p)$data[[length(p$layers)]]
  below <- al$tradeoff_table$compliance < al$compliance_threshold
  expect_true(any(below) && any(!below))
  expect_true(all(labels$vjust[below] > 1))
  expect_true(all(labels$vjust[!below] < 0))
})

test_that("colour-bar legends are wide enough for their break labels", {
  sim <- load_example_data()
  heat <- plot_scenario_heatmap(sim)
  expect_equal(as.numeric(heat$theme$legend.key.width), 2.5)
  sdi <- tibble::tibble(region = c("Low", "High"), sdi_median = c(0.5, 1.5))
  expect_equal(as.numeric(plot_sdi_map(sdi)$theme$legend.key.width), 2.5)
})

test_that("AL trade-off whiskers are visible and explained in the caption", {
  sim <- load_example_data()
  al <- al_efficiency(sim, al_scenarios = c("0" = "A-S00", "1" = "A-S01"),
                      n_bootstrap = 50, seed = 1)
  p <- plot_al_tradeoff(al)
  bars <- Filter(function(l) inherits(l$geom, "GeomErrorbar"), p$layers)[[1]]
  expect_gte(bars$aes_params$alpha, 0.8)
  expect_match(p$labels$caption, "95% percentile bootstrap interval",
               fixed = TRUE)
  no_ci <- al_efficiency(sim, al_scenarios = c("0" = "A-S00", "1" = "A-S01"),
                         n_bootstrap = 0)
  expect_no_match(plot_al_tradeoff(no_ci)$labels$caption, "Whiskers")
})
