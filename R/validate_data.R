#' Validate a dynasimR_data object
#'
#' Checks required columns, nonmissing scenario/replication identifiers,
#' numeric types, finite observed values and bounded rates. Entity and
#' time-series scenario/replication pairs must occur in the summary table.
#' Missing measurements are allowed; analysis functions document their
#' treatment. Data values are not modified.
#'
#' @param x A `dynasimR_data` object (list with `summary`, `entities`,
#'   `timeseries`).
#' @param strict Logical. If `TRUE`, any validation issue aborts;
#'   if `FALSE` (default), issues produce warnings and the function
#'   still returns `x`.
#' @return The input `x`, invisibly, with current issues in the
#'   `validation_issues` attribute, or no such attribute when valid.
#' @export
validate_dynasimR_data <- function(x, strict = FALSE) {
  if (!is.list(x)) cli::cli_abort("{.arg x} must be a list of tables.")
  if (!is.logical(strict) || length(strict) != 1L || is.na(strict))
    cli::cli_abort("{.arg strict} must be TRUE or FALSE.")
  issues <- character()
  add_issue <- function(msg) issues <<- c(issues, msg)
  rates <- c("event_rate", "compliance_index", "severity", "completion_rate")
  nonnegative <- c("time_step", "wait_days", "wait_days_to_min", "supply", "demand")
  numeric_cols <- c(rates, nonnegative, "progress_start", "progress_end",
                    "progress_gain", "progress")
  for (nm in c("summary", "entities", "timeseries")) {
    tbl <- x[[nm]]
    if (is.null(tbl)) next
    if (!is.data.frame(tbl)) {
      add_issue(paste(nm, "must be a data frame"))
      next
    }
    if (anyDuplicated(names(tbl)) || any(!nzchar(names(tbl))))
      add_issue(paste(nm, "has duplicate or empty column names"))
    if (nrow(tbl) == 0L) next
    req <- c("scenario", "replication", if (nm == "timeseries") "time_step")
    missing <- setdiff(req, names(tbl))
    if (length(missing) > 0L)
      add_issue(paste0(nm, " missing: ", paste(missing, collapse = ", ")))
    for (col in intersect(c("scenario", "replication"), names(tbl))) {
      value <- tbl[[col]]
      if (anyNA(value) || any(!nzchar(trimws(as.character(value)))) ||
          (is.numeric(value) && any(!is.finite(value))))
        add_issue(paste(nm, col,
                        "must contain nonmissing, nonblank identifiers (finite when numeric)"))
    }
    for (col in intersect(numeric_cols, names(tbl))) {
      value <- tbl[[col]]
      if (!is.numeric(value) && !(is.logical(value) && all(is.na(value)))) {
        add_issue(paste(nm, col, "must be numeric"))
        next
      }
      if (any(!is.na(value) & !is.finite(value)))
        add_issue(paste(nm, col, "must contain finite observed values"))
      if (col %in% rates && any(value < 0 | value > 1, na.rm = TRUE))
        add_issue(paste(nm, col, "has values outside [0, 1]"))
      if (col %in% nonnegative && any(value < 0, na.rm = TRUE))
        add_issue(paste(nm, col, "must be nonnegative"))
    }
  }
  keys <- c("scenario", "replication")
  has_keys <- function(tbl) is.data.frame(tbl) && nrow(tbl) > 0L &&
    all(keys %in% names(tbl))
  as_keys <- function(tbl) {
    out <- tbl[keys]
    out[] <- lapply(out, as.character)
    unique(out)
  }
  if (has_keys(x$summary)) {
    for (nm in c("entities", "timeseries")) {
      if (has_keys(x[[nm]]) &&
          nrow(dplyr::anti_join(as_keys(x[[nm]]), as_keys(x$summary),
                               by = keys)) > 0L)
        add_issue(paste(nm, "has scenario/replication pairs absent from summary"))
    }
  }
  issues <- unique(issues)
  attr(x, "validation_issues") <- if (length(issues)) issues else NULL
  if (length(issues) > 0L) {
    if (strict) cli::cli_abort(paste(issues, collapse = "; "))
    for (msg in issues) cli::cli_warn(msg)
  }
  invisible(x)
}
