make_profile_b <- function() {
  set.seed(41)
  n <- 30
  ent <- tibble::tibble(
    scenario       = rep(c("B-S00", "B-S19"), each = n),
    replication    = rep(1:n, 2),
    entity_id      = 1:(2 * n),
    progress_start = stats::rnorm(2 * n, 60, 10),
    progress_end   = stats::rnorm(2 * n, 95, 8)
  )
  summ <- tibble::tibble(
    scenario        = rep(c("B-S00", "B-S19"), each = n),
    replication     = rep(1:n, 2),
    completion_rate = stats::runif(2 * n, 0.4, 0.9),
    cost            = stats::runif(2 * n, 1000, 5000),
    region          = rep(c("RegA", "RegB", "RegC"), length.out = 2 * n),
    supply          = stats::runif(2 * n, 80, 120),
    demand          = stats::runif(2 * n, 80, 120)
  )
  structure(
    list(summary = summ, entities = ent,
         timeseries = tibble::tibble(),
         metadata = tibble::tibble(id = unique(summ$scenario)),
         load_info = list(profile_type = "Profile_B",
                          scenarios = unique(summ$scenario))),
    class = c("dynasimR_data", "list")
  )
}

test_that("plot_progress_curves falls back to bar chart on summary", {
  sim <- make_profile_b()
  pr <- progress_trajectory(sim)
  p <- plot_progress_curves(pr)
  expect_s3_class(p, "ggplot")
})

test_that("plot_progress_curves draws lines with longitudinal data", {
  long <- tibble::tibble(
    scenario        = rep(c("B-S00", "B-S19"), each = 5),
    time_step       = rep(1:5, 2),
    progress_median = stats::runif(10, 50, 90),
    progress_q025   = stats::runif(10, 40, 50),
    progress_q975   = stats::runif(10, 90, 99)
  )
  pr <- structure(
    list(summary = tibble::tibble(), longitudinal = long,
         params = list()),
    class = c("dynasimR_progress", "list")
  )
  p <- plot_progress_curves(pr, show_ci = TRUE)
  expect_s3_class(p, "ggplot")
  p2 <- plot_progress_curves(pr, show_ci = FALSE)
  expect_s3_class(p2, "ggplot")
})

test_that("plot_progress_curves rejects wrong class", {
  expect_error(plot_progress_curves(list()), "dynasimR_progress")
})

test_that("plot_sdi_map renders bar variant (no x/y)", {
  sim <- make_profile_b()
  sdi <- spatial_supply_demand(sim)
  p <- plot_sdi_map(sdi)
  expect_s3_class(p, "ggplot")
})

test_that("plot_sdi_map renders tile variant (with x/y)", {
  sim <- make_profile_b()
  sdi <- spatial_supply_demand(sim)
  sdi$x <- seq_len(nrow(sdi))
  sdi$y <- rev(seq_len(nrow(sdi)))
  p <- plot_sdi_map(sdi)
  expect_s3_class(p, "ggplot")
})

test_that("plot_cost_effectiveness CE plane", {
  sim <- make_profile_b()
  p <- plot_cost_effectiveness(sim, reference = "B-S00",
                               scenarios = "B-S19")
  expect_s3_class(p, "ggplot")
})

test_that("plot_cost_effectiveness CEAC curve", {
  sim <- make_profile_b()
  p <- plot_cost_effectiveness(sim, reference = "B-S00",
                               scenarios = "B-S19",
                               show_ceac = TRUE)
  expect_s3_class(p, "ggplot")
})

test_that("plot_cost_effectiveness aborts on unknown reference", {
  sim <- make_profile_b()
  expect_error(
    plot_cost_effectiveness(sim, reference = "ZZZ",
                            scenarios = "B-S19"),
    "Reference"
  )
})
