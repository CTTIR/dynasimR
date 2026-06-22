test_that("export_figure aborts on unknown format", {
  skip_if_not_installed("ggplot2")
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, hp)) +
    ggplot2::geom_point()
  tmp <- withr::local_tempfile(fileext = ".xyz")
  expect_error(export_figure(p, tmp), "Unknown format")
})

test_that("export_figure writes a png", {
  skip_if_not_installed("ggplot2")
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, hp)) +
    ggplot2::geom_point()
  tmp <- withr::local_tempfile(fileext = ".png")
  export_figure(p, tmp, width_mm = 80, height_mm = 60, dpi = 72)
  expect_true(file.exists(tmp))
})

test_that("export_latex_table errors when xtable missing", {
  testthat::local_mocked_bindings(
    requireNamespace = function(package, ...) {
      if (identical(package, "xtable")) return(FALSE)
      TRUE
    },
    .package = "base"
  )
  tmp <- withr::local_tempfile(fileext = ".tex")
  expect_error(
    export_latex_table(head(iris), tmp, caption = "c", label = "l"),
    "xtable"
  )
})

test_that("export_latex_table appends a footnote when supplied", {
  skip_if_not_installed("xtable")
  tmp <- withr::local_tempfile(fileext = ".tex")
  export_latex_table(head(iris), tmp, caption = "Cap",
                     label = "tab1", note = "A footnote here.")
  tex <- paste(readLines(tmp), collapse = "\n")
  expect_match(tex, "tablenotes")
  expect_match(tex, "A footnote here")
})

test_that("export_latex_table escapes angle brackets in cells", {
  skip_if_not_installed("xtable")
  tmp <- withr::local_tempfile(fileext = ".tex")
  df <- tibble::tibble(label = c("a < b", "c > d"), value = c(1, 2))
  export_latex_table(df, tmp, caption = "Cap", label = "tab2")
  tex <- paste(readLines(tmp), collapse = "\n")
  expect_match(tex, "\\$<\\$")
})

test_that("fill_placeholders aborts on missing file", {
  sim <- load_example_data()
  expect_error(
    fill_placeholders(sim, "no-such-file.tex"),
    "not found"
  )
})

test_that("fill_placeholders writes default _filled output", {
  sim <- load_example_data()
  tmpdir <- withr::local_tempdir()
  intex <- file.path(tmpdir, "doc.tex")
  writeLines("Baseline [XX_EVENT_BASELINE] best [XX_EVENT_BEST]", intex)
  reps <- fill_placeholders(sim, intex,
                            policy_a_scenario = "A-S08",
                            policy_b_scenario = "A-S07",
                            baseline_scenario = "A-S00")
  expect_true(file.exists(file.path(tmpdir, "doc_filled.tex")))
  expect_true("[XX_EVENT_BASELINE]" %in% names(reps))
})

test_that("fill_placeholders dry-run replacements are stable", {
  sim <- load_example_data()
  tmp <- withr::local_tempfile(fileext = ".tex")
  writeLines("[XX_EVENT_BASELINE] [XX_EVENT_BEST]", tmp)
  reps <- fill_placeholders(sim, tmp, dry_run = TRUE,
                            policy_a_scenario = "A-S08",
                            policy_b_scenario = "A-S07",
                            baseline_scenario = "A-S00")
  expect_equal(unname(reps[["[XX_EVENT_BASELINE]"]]), "34.1")
})
