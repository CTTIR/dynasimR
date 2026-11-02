#' Export a ggplot in publication-ready format
#'
#' Writes a ggplot2 object to PDF/SVG/PNG/TIFF/EPS at the specified
#' physical dimensions (in millimetres) and resolution.
#'
#' @param plot A ggplot2 object.
#' @param filename Character. Output path (extension determines format
#'   unless `format` is supplied).
#' @param width_mm Numeric. Width in mm. `88` approximates one column and
#'   `174` two columns; check the target journal's dimensions. Default `174`.
#' @param height_mm Numeric. Height in mm. Default `120`.
#' @param dpi Integer. Raster resolution. Default `300`.
#' @param format Character. Optional explicit format (`pdf`, `svg`, `png`,
#'   `tiff`, or `eps`), useful for extensionless download staging paths.
#' @return Invisibly, the filename.
#' @export
#' @examples
#' \dontrun{
#' p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, hp)) +
#'   ggplot2::geom_point()
#' export_figure(p, "mtcars.pdf", width_mm = 120, height_mm = 90)
#' }
export_figure <- function(plot,
                          filename,
                          width_mm  = 174,
                          height_mm = 120,
                          dpi       = 300,
                          format    = NULL) {

  fmt <- if (is.null(format)) tolower(tools::file_ext(filename)) else
    tolower(format)
  if (length(fmt) != 1L || is.na(fmt) ||
      !fmt %in% c("pdf", "svg", "png", "tiff", "eps"))
    cli::cli_abort("Unknown format: {.val {fmt}}")

  ggplot2::ggsave(
    filename = filename,
    plot     = plot,
    width    = width_mm  / 25.4,
    height   = height_mm / 25.4,
    dpi      = dpi,
    device   = if (fmt == "svg") grDevices::svg else fmt
  )

  cli::cli_alert_success(
    "Figure saved: {.path {filename}} ({width_mm}x{height_mm} mm)"
  )
  invisible(filename)
}

#' Export a tibble as a publication-quality LaTeX table
#'
#' Produces a `booktabs`-style table using `\\botrule` instead of
#' `\\bottomrule`. Cells, column names, captions and notes are treated as
#' literal text and escaped once. Notes use a `threeparttable` environment.
#' The document needs `booktabs` and, for notes, `threeparttable`; outside
#' a publisher class defining `\\botrule`, add
#' `\\providecommand{\\botrule}{\\bottomrule}` to the preamble.
#'
#' @param data A tibble/data.frame.
#' @param filename Character. Output `.tex` path.
#' @param caption Character. Table caption.
#' @param label Character. LaTeX label (without the `tab:` prefix;
#'   it will be added). Use letters, digits, colons, periods, underscores
#'   and hyphens, starting with a letter or digit.
#' @param note Character. Optional footnote text.
#' @param digits Integer. Digits for numeric columns. Default `3`.
#' @param col_format Character vector. Column alignment spec
#'   (e.g. `c("l", "r", "r")`). Default `NULL` picks `"l"` for the
#'   first column and `"r"` for the rest.
#' @return The LaTeX source, invisibly.
#' @export
#' @examples
#' \dontrun{
#' export_latex_table(head(iris), "iris.tex",
#'                    caption = "First rows of iris.",
#'                    label   = "iris")
#' }
export_latex_table <- function(data,
                               filename,
                               caption,
                               label,
                               note       = NULL,
                               digits     = 3,
                               col_format = NULL) {

  if (!requireNamespace("xtable", quietly = TRUE))
    cli::cli_abort(
      "Package {.pkg xtable} required. ",
      "Install with {.code install.packages('xtable')}."
    )

  if (length(label) != 1L || is.na(label) ||
      !grepl("^[A-Za-z0-9][A-Za-z0-9:._-]*$", label))
    cli::cli_abort("{.arg label} must be a simple LaTeX label identifier.")
  if (length(caption) != 1L || is.na(caption) ||
      (!is.null(note) && (length(note) != 1L || is.na(note))))
    cli::cli_abort("{.arg caption} and {.arg note} must each be a single non-missing string.")

  n_col <- ncol(data)
  if (is.null(col_format))
    col_format <- c("l", rep("r", max(0, n_col - 1)))

  tab <- xtable::xtable(
    data,
    digits  = digits,
    align   = c("l", col_format)
  )

  tex_str <- xtable::print.xtable(
    tab,
    type             = "latex",
    floating         = FALSE,
    latex.environments = NULL,
    booktabs         = TRUE,
    include.rownames = FALSE,
    print.results    = FALSE,
    comment          = FALSE,
    sanitize.text.function = .escape_latex_text,
    sanitize.colnames.function = .escape_latex_text
  )

  tex_str <- .sn_replace_bottomrule(tex_str)

  tex_str <- paste0(
    "\\begin{table}[ht]\n\\centering\n",
    if (!is.null(note)) "\\begin{threeparttable}\n",
    tex_str,
    if (!is.null(note)) paste0("\\begin{tablenotes}\n\\item ",
                              .escape_latex_text(note),
                              "\n\\end{tablenotes}\n"),
    "\\caption{", .escape_latex_text(caption), "}\n",
    "\\label{tab:", label, "}\n",
    if (!is.null(note)) "\\end{threeparttable}\n",
    "\\end{table}\n"
  )

  writeLines(tex_str, filename)
  cli::cli_alert_success("LaTeX table: {.path {filename}}")
  invisible(tex_str)
}

#' Fill `[XX_*]` placeholders in a LaTeX manuscript
#'
#' Substitutes `[XX_*]` placeholders in a LaTeX source file with
#' automatically computed simulation statistics. The mapping from
#' placeholder to computation is assembled inside this function from
#' [policy_effect()], [al_efficiency()] and
#' [compute_compliance_index()].
#'
#' @param sim_data A `dynasimR_data` object.
#' @param tex_file Character. Path to the LaTeX source file.
#' @param output_file Character. Output path; default appends
#'   `_filled` before `.tex` (case insensitive), or `_filled.tex` to a
#'   filename without that extension. The source is never overwritten.
#' @param dry_run Logical. If `TRUE`, print replacements but do not
#'   write a file. Default `FALSE`.
#' @param policy_a_scenario Character. Policy A scenario ID.
#'   Default `"A-S08"`.
#' @param policy_b_scenario Character. Policy B scenario ID.
#'   Default `"A-S07"`.
#' @param baseline_scenario Character. Baseline scenario ID.
#'   Default `"A-S00"`.
#' @param overwrite Logical. Allow replacement of an existing output file.
#'   Default `FALSE`. This never permits overwriting the source manuscript.
#' @details Policy event differences and their confidence limits use the
#'   signed A-minus-B convention, in percentage points. A write is refused
#'   if the manuscript requests unknown placeholders or unavailable/non-finite
#'   statistics. `dry_run = TRUE` reports these without writing a file.
#' @return Named character vector of the replacements (invisibly).
#' @export
fill_placeholders <- function(sim_data,
                              tex_file,
                              output_file        = NULL,
                              dry_run            = FALSE,
                              policy_a_scenario  = "A-S08",
                              policy_b_scenario  = "A-S07",
                              baseline_scenario  = "A-S00",
                              overwrite          = FALSE) {

  for (name in c("tex_file", "policy_a_scenario", "policy_b_scenario",
                 "baseline_scenario")) {
    value <- get(name)
    if (!is.character(value) || length(value) != 1L ||
        is.na(value) || !nzchar(value))
      cli::cli_abort("{name} must be a single non-empty string.")
  }
  if (!is.null(output_file) &&
      (!is.character(output_file) || length(output_file) != 1L ||
       is.na(output_file) || !nzchar(output_file)))
    cli::cli_abort("{.arg output_file} must be a single non-empty path.")
  for (name in c("dry_run", "overwrite")) {
    value <- get(name)
    if (!is.logical(value) || length(value) != 1L || is.na(value))
      cli::cli_abort("{name} must be TRUE or FALSE.")
  }
  if (!file.exists(tex_file))
    cli::cli_abort("File not found: {.path {tex_file}}")

  if (!dry_run) {
    if (is.null(output_file)) {
      output_file <- if (grepl("\\.tex$", tex_file, ignore.case = TRUE))
        sub("\\.tex$", "_filled.tex", tex_file, ignore.case = TRUE) else
          paste0(tex_file, "_filled.tex")
    }
    if (!dir.exists(dirname(output_file)))
      cli::cli_abort("Output directory not found: {.path {dirname(output_file)}}")
    source_path <- normalizePath(tex_file, mustWork = TRUE)
    output_path <- if (file.exists(output_file))
      normalizePath(output_file, mustWork = TRUE) else
        file.path(normalizePath(dirname(output_file), mustWork = TRUE),
                  basename(output_file))
    if (identical(source_path, output_path))
      cli::cli_abort("Output must differ from the source manuscript.")
    if (file.exists(output_file) && !isTRUE(overwrite))
      cli::cli_abort("Output already exists: {.path {output_file}}. Use {.code overwrite = TRUE} to replace it.")
  }

  pol <- try(policy_effect(
    sim_data,
    policy_a_scenario = policy_a_scenario,
    policy_b_scenario = policy_b_scenario
  ), silent = TRUE)
  al  <- try(al_efficiency(sim_data), silent = TRUE)
  ci  <- try(compute_compliance_index(sim_data, by_group = FALSE),
             silent = TRUE)

  get_num <- function(tbl, scenario_id, column) {
    if (inherits(tbl, "try-error")) return(NA_real_)
    subs <- tbl[!is.na(tbl$scenario) & tbl$scenario == scenario_id, , drop = FALSE]
    if (nrow(subs) == 0) return(NA_real_)
    as.numeric(subs[[column]][1])
  }

  s <- sim_data$summary

  replacements <- c(
    "[XX_POLICY_DELTA_EVENT]" =
      if (inherits(pol, "try-error")) "NA" else
        as.character(round(
          pol$delta_event$median_pct_points[
            pol$delta_event$group == "all"][1], 1)),
    "[XX_POLICY_DELTA_CI_LO]" =
      if (inherits(pol, "try-error")) "NA" else
        as.character(round(
          pol$delta_event$ci_lo[
            pol$delta_event$group == "all"][1], 1)),
    "[XX_POLICY_DELTA_CI_HI]" =
      if (inherits(pol, "try-error")) "NA" else
        as.character(round(
          pol$delta_event$ci_hi[
            pol$delta_event$group == "all"][1], 1)),
    "[XX_COMPLIANCE_A]" =
      as.character(round(get_num(ci,
        policy_a_scenario, "ci"), 3)),
    "[XX_COMPLIANCE_B]" =
      as.character(round(get_num(ci,
        policy_b_scenario, "ci"), 3)),
    "[XX_OPTIMAL_AL]" =
      if (inherits(al, "try-error")) "NA" else
        as.character(al$optimal_al),
    "[XX_EVENT_BASELINE]" = as.character(round(
      stats::median(s$event_rate[s$scenario == baseline_scenario],
                    na.rm = TRUE) * 100, 1)),
    "[XX_EVENT_BEST]" = as.character(round(
      min(tapply(s$event_rate, s$scenario,
                 stats::median, na.rm = TRUE), na.rm = TRUE) * 100,
      1))
  )

  cli::cli_h2("Placeholder substitutions")
  purrr::walk2(
    names(replacements), replacements,
    ~ cli::cli_bullets(c("*" = "{.code {.x}} -> {.val {.y}}"))
  )

  tex <- readLines(tex_file)
  requested <- unique(unlist(regmatches(tex,
    gregexpr("\\[XX_[^]]*\\]", tex, perl = TRUE)), use.names = FALSE))
  known <- intersect(requested, names(replacements))
  unavailable <- known[!is.finite(suppressWarnings(
    as.numeric(replacements[known])))]
  unresolved <- union(setdiff(requested, names(replacements)), unavailable)
  if (length(unresolved)) {
    if (dry_run)
      cli::cli_alert_warning("Unresolved manuscript placeholders: {.val {unresolved}}")
    else
      cli::cli_abort("Cannot fill unresolved manuscript placeholders: {.val {unresolved}}. No file was written.")
  }
  if (dry_run) {
    cli::cli_alert_info("Dry run: no file written.")
    return(invisible(replacements))
  }

  for (i in seq_along(replacements))
    tex <- gsub(names(replacements)[i],
                replacements[i], tex, fixed = TRUE)

  staging <- tempfile(".dynasimR-filled-", tmpdir = dirname(output_file))
  on.exit(unlink(staging), add = TRUE)
  writeLines(tex, staging)
  if (!file.rename(staging, output_file))
    cli::cli_abort("Could not write output: {.path {output_file}}")
  cli::cli_alert_success("Filled: {.path {output_file}}")
  invisible(replacements)
}
