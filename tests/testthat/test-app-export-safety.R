test_that("placeholder IDs are literal and policy differences retain their sign", {
  sim <- load_example_data()
  tmp <- withr::local_tempdir()
  source <- file.path(tmp, "input.tex")
  canary <- file.path(tmp, "executed.txt")
  writeLines("[XX_COMPLIANCE_A] [XX_POLICY_DELTA_EVENT]", source)
  id <- paste0("A' | {writeLines('executed', '", canary,
               "'); FALSE} | scenario == 'A")
  for (name in names(sim)) {
    if (is.data.frame(sim[[name]]) && "scenario" %in% names(sim[[name]]))
      sim[[name]]$scenario[sim[[name]]$scenario == "A-S08"] <- id
  }
  set.seed(42)
  reps <- fill_placeholders(sim, source, dry_run = TRUE,
                             policy_a_scenario = id)
  expect_false(file.exists(canary))
  expect_true(is.finite(as.numeric(reps[["[XX_COMPLIANCE_A]"]])))
  expect_equal(as.numeric(reps[["[XX_POLICY_DELTA_EVENT]"]]), -7.4)
  expect_lt(as.numeric(reps[["[XX_POLICY_DELTA_CI_HI]"]]), 0)
})

test_that("manuscript writes preserve source bytes and existing outputs", {
  sim <- load_example_data()
  tmp <- withr::local_tempdir()
  for (name in c("input.TEX", "extensionless")) {
    source <- file.path(tmp, name)
    writeLines("Baseline [XX_EVENT_BASELINE]", source)
    hash <- unname(tools::md5sum(source))
    fill_placeholders(sim, source)
    output <- file.path(tmp, if (name == "input.TEX")
      "input_filled.tex" else "extensionless_filled.tex")
    expect_identical(readLines(output), "Baseline 34.1")
    expect_identical(unname(tools::md5sum(source)), hash)
    expect_error(fill_placeholders(sim, source,
      output_file = file.path(tmp, ".", name), overwrite = TRUE),
      "differ from the source")
    writeLines("Existing work", output)
    expect_error(fill_placeholders(sim, source), "already exists")
    expect_identical(readLines(output), "Existing work")
    fill_placeholders(sim, source, overwrite = TRUE)
    expect_identical(readLines(output), "Baseline 34.1")
    expect_identical(unname(tools::md5sum(source)), hash)
  }
})

test_that("literal LaTeX text and notes produce a compilable table", {
  skip_if_not_installed("xtable")
  tmp <- withr::local_tempdir()
  literal <- "x_1 & 5% < y > $z$ # {a} \\input{missing} ^ ~ |"
  tex <- export_latex_table(
    data.frame("A&B" = factor(literal), value = 1, check.names = FALSE),
    file.path(tmp, "table.tex"), caption = literal, label = "literal",
    note = literal
  )
  expect_match(tex, "\\begin{threeparttable}", fixed = TRUE)
  expect_match(tex, "\\begin{tablenotes}", fixed = TRUE)
  expect_match(tex, "\\textbackslash{}input\\{missing\\}", fixed = TRUE)
  expect_match(tex, "5\\% $<$ y $>$", fixed = TRUE)
  expect_false(grepl("\\$$<$\\$", tex, fixed = TRUE))
  expect_error(export_latex_table(data.frame(x = 1),
    file.path(tmp, "unsafe.tex"), "Caption", "x}\\input{missing}"),
    "label identifier")
  skip_if(!nzchar(Sys.which("pdflatex")), "pdflatex not installed")
  skip_if(!nzchar(Sys.which("kpsewhich")), "TeX prerequisite lookup unavailable")
  for (package in c("booktabs.sty", "threeparttable.sty")) {
    found <- suppressWarnings(system2(Sys.which("kpsewhich"), package,
                                      stdout = TRUE, stderr = FALSE))
    skip_if(!length(found), paste(package, "not installed"))
  }
  writeLines(c("\\documentclass{article}", "\\usepackage[T1]{fontenc}",
    "\\usepackage{booktabs,threeparttable}",
    "\\providecommand{\\botrule}{\\bottomrule}",
    "\\begin{document}", "\\input{table.tex}", "\\end{document}"),
    file.path(tmp, "document.tex"))
  withr::local_dir(tmp)
  result <- suppressWarnings(system2(Sys.which("pdflatex"),
    c("-interaction=nonstopmode", "-halt-on-error", "-no-shell-escape",
      "document.tex"), stdout = TRUE, stderr = TRUE))
  status <- attr(result, "status")
  expect_true(is.null(status) || status == 0L,
              info = paste(tail(result, 20), collapse = "\n"))
  expect_true(file.exists("document.pdf"))
})

test_that("unresolved requested placeholders cannot replace existing work", {
  sim <- load_example_data()
  tmp <- withr::local_tempdir()
  source <- file.path(tmp, "input.tex")
  output <- file.path(tmp, "output.tex")
  for (placeholder in c("[XX_OPTIMAL_AL]", "[XX_UNKNOWN]")) {
    writeLines(paste("Baseline [XX_EVENT_BASELINE]", placeholder), source)
    writeLines("Existing output", output)
    before <- tools::md5sum(c(source, output))
    expect_error(fill_placeholders(sim, source, output, overwrite = TRUE),
                  "unresolved manuscript placeholders")
    expect_identical(tools::md5sum(c(source, output)), before)
    reps <- fill_placeholders(sim, source, output, dry_run = TRUE)
    expect_equal(reps[["[XX_EVENT_BASELINE]"]], "34.1")
    expect_identical(tools::md5sum(c(source, output)), before)
  }
})

test_that("explicit figure formats work without a filename extension", {
  tmp <- withr::local_tempdir()
  plot <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, hp)) +
    ggplot2::geom_point()
  for (format in c("pdf", "png", "svg")) {
    if (format == "svg" && !capabilities("cairo")) next
    path <- file.path(tmp, format)
    export_figure(plot, path, width_mm = 80, height_mm = 60,
                   dpi = 72, format = format)
    raw <- readBin(path, "raw", n = 100)
    if (format == "pdf") expect_identical(rawToChar(raw[1:5]), "%PDF-")
    if (format == "png") expect_identical(raw[1:8],
      as.raw(c(137, 80, 78, 71, 13, 10, 26, 10)))
    if (format == "svg") expect_match(rawToChar(raw), "<?xml", fixed = TRUE)
  }
})
