test_that("missing and empty graphics output cannot report success", {
  root <- withr::local_tempdir()
  output <- file.path(root, "figure.svg")
  plot <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, hp)) + ggplot2::geom_point()
  for (empty in c(FALSE, TRUE)) {
    local_mocked_bindings(ggsave = function(filename, ...) {
      if (empty) file.create(filename)
      warning("synthetic graphics library unavailable")
      invisible(filename)
    }, .package = "ggplot2")
    for (existing in c(FALSE, TRUE)) {
      if (existing) writeLines("previous figure", output)
      expect_error(expect_warning(export_figure(plot, output),
                                  "synthetic graphics library unavailable"),
                    "did not create a nonempty figure")
      if (existing) expect_identical(readLines(output), "previous figure") else
        expect_false(file.exists(output))
      expect_setequal(list.files(root, all.files = TRUE, no.. = TRUE),
                      if (existing) "figure.svg" else character())
      unlink(output)
    }
  }
})

test_that("partial device output is cleaned without replacing a previous figure", {
  root <- withr::local_tempdir()
  output <- file.path(root, "figure.pdf")
  writeLines("previous figure", output)
  local_mocked_bindings(ggsave = function(filename, ...) {
    writeLines("partial output", filename)
    stop("synthetic device failure")
  }, .package = "ggplot2")
  plot <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, hp)) + ggplot2::geom_point()
  expect_error(export_figure(plot, output), "synthetic device failure")
  expect_identical(readLines(output), "previous figure")
  expect_setequal(list.files(root, all.files = TRUE, no.. = TRUE), "figure.pdf")
})

test_that("a failed SVG device cannot draw on the caller's device", {
  root <- withr::local_tempdir()
  output <- file.path(root, "figure.svg")
  writeLines("previous SVG", output)
  withr::local_pdf(file.path(root, "caller.pdf"))
  before <- grDevices::dev.cur()
  drew <- FALSE
  original <- grid::grid.newpage
  local_mocked_bindings(grid.newpage = function(...) {
    drew <<- TRUE
    original(...)
  }, .package = "grid")
  local_mocked_bindings(svg = function(...) {
    warning("synthetic Cairo initialization failure")
    invisible(NULL)
  }, .package = "grDevices")
  plot <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, hp)) + ggplot2::geom_point()
  expect_error(expect_warning(export_figure(plot, output),
                              "synthetic Cairo initialization failure"),
                "SVG graphics device could not initialize")
  expect_false(drew)
  expect_identical(grDevices::dev.cur(), before)
  expect_identical(readLines(output), "previous SVG")
  expect_setequal(list.files(root, all.files = TRUE, no.. = TRUE),
                  c("caller.pdf", "figure.svg"))
})

test_that("publication failure restores the previous figure", {
  root <- withr::local_tempdir()
  stage <- file.path(root, "stage.pdf")
  output <- file.path(root, "figure.pdf")
  writeLines("new figure", stage)
  writeLines("previous figure", output)
  fail_publish <- function(from, to) {
    if (identical(from, stage)) FALSE else file.rename(from, to)
  }
  expect_error(.publish_figure_export(stage, output, rename = fail_publish),
                "Cannot publish")
  expect_identical(readLines(output), "previous figure")
  expect_identical(readLines(stage), "new figure")
  expect_setequal(list.files(root, all.files = TRUE, no.. = TRUE),
                  c("figure.pdf", "stage.pdf"))
})

test_that("a real replacement export leaves only the requested figure", {
  root <- withr::local_tempdir()
  plot <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, hp)) + ggplot2::geom_point()
  for (format in c("pdf", "png", "svg", "tiff", "eps")) {
    if (format == "svg" && !capabilities("cairo")) next
    output <- file.path(root, paste0("figure.", format))
    writeLines("previous figure", output)
    expect_identical(export_figure(plot, output, width_mm = 80, height_mm = 60,
                                   dpi = 72), output)
    header <- readBin(output, "raw", n = 100)
    if (format == "pdf") expect_identical(rawToChar(header[1:5]), "%PDF-")
    if (format == "png") expect_identical(header[1:8], as.raw(c(137, 80, 78, 71, 13, 10, 26, 10)))
    if (format == "svg") expect_match(rawToChar(header), "<?xml", fixed = TRUE)
    if (format == "tiff") expect_true(identical(header[1:4], as.raw(c(73, 73, 42, 0))) ||
                                       identical(header[1:4], as.raw(c(77, 77, 0, 42))))
    if (format == "eps") expect_identical(rawToChar(header[1:10]), "%!PS-Adobe")
    expect_gt(file.info(output)$size, 500)
    expect_setequal(list.files(root, all.files = TRUE, no.. = TRUE), basename(output))
    unlink(output)
  }
})

test_that("failed restoration retains and identifies the previous output", {
  root <- withr::local_tempdir()
  stage <- file.path(root, "stage.pdf")
  output <- file.path(root, "figure.pdf")
  writeLines("new figure", stage)
  writeLines("previous figure", output)
  backup <- NULL
  fail_after_backup <- function(from, to) {
    if (!identical(from, output)) return(FALSE)
    backup <<- to
    file.rename(from, to)
  }
  expect_error(expect_warning(.publish_figure_export(stage, output,
                                                     rename = fail_after_backup),
                               "Could not restore.*retained"), "Cannot publish")
  expect_identical(readLines(backup), "previous figure")
  expect_false(file.exists(output))
  expect_identical(readLines(stage), "new figure")
})
