test_that("al_efficiency aborts when reference scenario missing", {
  sim <- load_example_data()
  expect_error(
    al_efficiency(sim,
      al_scenarios = c("0" = "ZZZ", "1" = "A-S01"),
      n_bootstrap = 20),
    "Reference"
  )
})

test_that("al_efficiency skips scenarios absent from data", {
  sim <- load_example_data()
  al <- al_efficiency(sim,
    al_scenarios = c("0" = "A-S00", "1" = "A-S01", "2" = "NOPE"),
    n_bootstrap = 20)
  expect_false("NOPE" %in% al$tradeoff_table$scenario)
})

test_that("al_efficiency optimal_al is NA when none compliant", {
  sim <- load_example_data()
  al <- al_efficiency(sim,
    al_scenarios = c("0" = "A-S00", "1" = "A-S01"),
    compliance_threshold = 0.999,
    n_bootstrap = 20)
  expect_true(is.na(al$optimal_al))
  expect_gt(nrow(al$compliance_violations), 0)
})

test_that("print.dynasimR_al_analysis is invisible", {
  sim <- load_example_data()
  al <- al_efficiency(sim,
    al_scenarios = c("0" = "A-S00", "1" = "A-S01"),
    n_bootstrap = 20)
  expect_invisible(print(al))
})
