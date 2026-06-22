test_that(".boot_quantile_ci returns NA for short input", {
  expect_equal(dynasimR:::.boot_quantile_ci(c(1)),
               c(NA_real_, NA_real_))
})

test_that(".boot_quantile_ci is reproducible with a seed", {
  a <- dynasimR:::.boot_quantile_ci(1:100, n_boot = 200, seed = 7)
  b <- dynasimR:::.boot_quantile_ci(1:100, n_boot = 200, seed = 7)
  expect_equal(a, b)
  expect_length(a, 2)
})

test_that(".boot_diff_ci returns a length-2 vector", {
  d <- dynasimR:::.boot_diff_ci(1:50, 11:60, n_boot = 200, seed = 9)
  expect_length(d, 2)
  expect_true(d[1] <= d[2])
})

test_that(".safe_viridis returns n colours", {
  cols <- dynasimR:::.safe_viridis(4)
  expect_length(cols, 4)
  expect_true(all(grepl("^#", cols)))
})

test_that(".safe_viridis falls back when viridis is missing", {
  testthat::local_mocked_bindings(
    requireNamespace = function(...) FALSE,
    .package = "base"
  )
  cols <- dynasimR:::.safe_viridis(3)
  expect_length(cols, 3)
})

test_that(".escape_latex_math escapes angle brackets", {
  expect_equal(dynasimR:::.escape_latex_math("a < b > c"),
               "a $<$ b $>$ c")
  expect_null(dynasimR:::.escape_latex_math(NULL))
})

test_that(".sn_replace_bottomrule swaps the rule macro", {
  out <- dynasimR:::.sn_replace_bottomrule("x \\bottomrule y")
  expect_match(out, "\\\\botrule")
  expect_false(grepl("bottomrule", out))
})

test_that(".format_p formats p-values across thresholds", {
  expect_equal(dynasimR:::.format_p(NA), "NA")
  expect_equal(dynasimR:::.format_p(0.0001), "< 0.001")
  expect_equal(dynasimR:::.format_p(0.005), "0.005")
  expect_equal(dynasimR:::.format_p(0.04), "0.040")
})

test_that(".require_cols aborts on missing, passes when present", {
  df <- tibble::tibble(a = 1, b = 2)
  expect_true(dynasimR:::.require_cols(df, c("a", "b")))
  expect_error(dynasimR:::.require_cols(df, c("a", "z")),
               "missing required")
})

test_that(".warn_cols warns on missing optional columns", {
  df <- tibble::tibble(a = 1)
  expect_warning(
    res <- dynasimR:::.warn_cols(df, c("a", "z")),
    "missing optional"
  )
  expect_false(res)
  expect_true(dynasimR:::.warn_cols(df, "a"))
})

test_that(".in_range warns on out-of-range values", {
  expect_warning(dynasimR:::.in_range(c(0.5, 2), 0, 1, "x"),
                 "outside")
  expect_true(dynasimR:::.in_range(c(0.1, 0.9), 0, 1, "x"))
})
