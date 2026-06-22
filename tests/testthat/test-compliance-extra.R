test_that("compute_compliance_index aborts without a time column", {
  ent <- tibble::tibble(scenario = "A-S00", replication = 1, x = 1)
  expect_error(compute_compliance_index(ent), "time_to_first_service")
})

test_that("compute_compliance_index returns empty tibble on empty input", {
  expect_equal(nrow(compute_compliance_index(tibble::tibble())), 0L)
})

test_that("compute_compliance_index unstratified path runs", {
  sim <- load_example_data()
  ci <- compute_compliance_index(sim, by_scenario = FALSE,
                                 by_group = FALSE, n_bootstrap = 0)
  expect_equal(nrow(ci), 1L)
  expect_true("compliance_critical" %in% names(ci))
})

test_that("compute_compliance_index uses wait_days_to_min fallback", {
  ent <- tibble::tibble(
    scenario = rep("B-S00", 10),
    replication = 1:10,
    wait_days_to_min = stats::runif(10, 0, 100)
  )
  ci <- compute_compliance_index(ent, window_min = 60,
                                 by_group = FALSE, n_bootstrap = 0)
  expect_true(all(ci$ci >= 0 & ci$ci <= 1))
})

test_that("policy_effect narrative is generated and non-trivial", {
  sim <- load_example_data()
  pol <- policy_effect(sim, "A-S08", "A-S07", n_bootstrap = 30)
  expect_invisible(print(pol))
  expect_match(pol$narrative, "policy A")
})
