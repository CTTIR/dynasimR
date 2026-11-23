# A supplied seed makes bootstrap intervals reproducible without changing
# the caller's RNG stream.

profile_b_runs <- function() {
  data.frame(
    scenario = rep(c("B-S00", "B-S01"), each = 12),
    replication = rep(1:12, 2),
    completion_rate = c(seq(0.50, 0.72, length.out = 12),
                        seq(0.58, 0.83, length.out = 12)),
    cost = c(seq(900, 1100, length.out = 12),
             seq(1000, 1300, length.out = 12))
  )
}

expect_seeded <- function(run) {
  first <- run(seed = 11)
  expect_identical(run(seed = 11), first)

  set.seed(2024)
  expected_next <- stats::runif(1)
  set.seed(2024)
  run(seed = 11)
  expect_identical(stats::runif(1), expected_next)
  first
}

test_that("policy_effect() is reproducible with a seed", {
  sim <- load_example_data()
  run <- function(seed) policy_effect(
    sim, policy_a_scenario = "A-S08", policy_b_scenario = "A-S07",
    n_bootstrap = 100, seed = seed
  )
  out <- expect_seeded(run)
  expect_identical(out$params$seed, 11)
  expect_true(all(is.finite(out$delta_event$ci_lo)))
  expect_error(run(seed = -1), "seed")
  expect_error(run(seed = "a"), "seed")
})

test_that("al_efficiency() is reproducible with a seed", {
  sim <- load_example_data()
  run <- function(seed) al_efficiency(
    sim, al_scenarios = c("0" = "A-S00", "1" = "A-S01"),
    n_bootstrap = 100, seed = seed
  )
  out <- expect_seeded(run)
  expect_identical(out$params$seed, 11)
  expect_error(run(seed = 1.5), "seed")
})

test_that("compliance and wait-gap indices are reproducible with a seed", {
  sim <- load_example_data()
  expect_seeded(function(seed) compute_compliance_index(
    sim, n_bootstrap = 100, seed = seed
  ))
  waits <- data.frame(
    scenario = rep(c("B-S00", "B-S01"), each = 20),
    wait_days = c(seq(1, 39, by = 2), seq(2, 21))
  )
  expect_seeded(function(seed) compute_wait_gap_index(
    waits, n_bootstrap = 100, seed = seed
  ))
  expect_error(compute_wait_gap_index(waits, seed = NA), "seed")
})

test_that("group_effect() is reproducible with a seed", {
  runs <- profile_b_runs()
  run <- function(seed) group_effect(
    runs, group_a_scenario = "B-S01", group_b_scenario = "B-S00",
    n_bootstrap = 100, seed = seed
  )
  out <- expect_seeded(run)
  expect_identical(out$params$seed, 11)
})

test_that("an unseeded bootstrap follows the caller's RNG", {
  runs <- profile_b_runs()
  run <- function() group_effect(
    runs, group_a_scenario = "B-S01", group_b_scenario = "B-S00",
    n_bootstrap = 100
  )$delta_completion
  set.seed(5)
  first <- run()
  set.seed(5)
  expect_identical(run(), first)
  expect_null(group_effect(runs, "B-S01", "B-S00", n_bootstrap = 0)$params$seed)
})

test_that("a seed set without a prior RNG state leaves none behind", {
  runs <- profile_b_runs()
  had_seed <- exists(".Random.seed", envir = globalenv(), inherits = FALSE)
  old_seed <- if (had_seed) get(".Random.seed", envir = globalenv())
  on.exit({
    if (had_seed) assign(".Random.seed", old_seed, envir = globalenv())
  }, add = TRUE)
  if (had_seed) rm(".Random.seed", envir = globalenv())
  group_effect(runs, "B-S01", "B-S00", n_bootstrap = 20, seed = 3)
  expect_false(exists(".Random.seed", envir = globalenv(), inherits = FALSE))
})
