test_that("fill_placeholders dry_run returns named replacements", {
  sim <- load_example_data()
  tmp <- tempfile(fileext = ".tex")
  on.exit(unlink(tmp), add = TRUE)
  writeLines("Event: [XX_POLICY_DELTA_EVENT]%", tmp)

  reps <- fill_placeholders(sim, tmp, dry_run = TRUE,
                            policy_a_scenario = "A-S08",
                            policy_b_scenario = "A-S07",
                            baseline_scenario = "A-S00")
  expect_true(is.character(reps))
  expect_true("[XX_POLICY_DELTA_EVENT]" %in% names(reps))
})

test_that("fill_placeholders writes a filled file", {
  sim <- load_example_data()
  in_tex  <- tempfile(fileext = ".tex")
  out_tex <- tempfile(fileext = ".tex")
  on.exit({ unlink(in_tex); unlink(out_tex) }, add = TRUE)
  writeLines(c("Event baseline: [XX_EVENT_BASELINE]%",
               "Best: [XX_EVENT_BEST]%"), in_tex)

  fill_placeholders(sim, in_tex, output_file = out_tex,
                    policy_a_scenario = "A-S08",
                    policy_b_scenario = "A-S07",
                    baseline_scenario = "A-S00")
  expect_true(file.exists(out_tex))
  filled <- paste(readLines(out_tex), collapse = "\n")
  expect_false(grepl("[XX_EVENT_BASELINE]", filled, fixed = TRUE))
})

test_that("fill_placeholders skips the unused compliance bootstrap", {
  sim <- load_example_data()
  real <- compute_compliance_index
  calls <- list()
  local_mocked_bindings(compute_compliance_index = function(...) {
    calls[[length(calls) + 1L]] <<- list(...)
    real(...)
  })
  tex <- withr::local_tempfile(fileext = ".tex")
  writeLines("Compliance: [XX_COMPLIANCE_A] and [XX_COMPLIANCE_B].", tex)

  reps <- fill_placeholders(sim, tex, dry_run = TRUE)

  expect_length(calls, 1L)
  expect_identical(calls[[1]]$n_bootstrap, 0)
  ci <- real(sim, by_group = FALSE)
  expect_identical(unname(reps["[XX_COMPLIANCE_A]"]),
                   as.character(round(ci$ci[ci$scenario == "A-S08"], 3)))
  expect_identical(unname(reps["[XX_COMPLIANCE_B]"]),
                   as.character(round(ci$ci[ci$scenario == "A-S07"], 3)))
})
