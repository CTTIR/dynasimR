# Internal validation helpers — not exported.

#' @keywords internal
#' @noRd
.require_cols <- function(x, cols, where = "input") {
  missing <- setdiff(cols, names(x))
  if (length(missing) > 0)
    cli::cli_abort(
      "{where} missing required column{?s}: {.val {missing}}"
    )
  invisible(TRUE)
}

#' @keywords internal
#' @noRd
.warn_cols <- function(x, cols, where = "input") {
  missing <- setdiff(cols, names(x))
  if (length(missing) > 0)
    cli::cli_warn(
      "{where} missing optional column{?s}: {.val {missing}}"
    )
  invisible(length(missing) == 0)
}

#' @keywords internal
#' @noRd
.in_range <- function(x, lo, hi, col_name = "value") {
  bad <- !is.na(x) & (x < lo | x > hi)
  if (any(bad))
    cli::cli_warn(
      "{sum(bad)} value(s) in {.field {col_name}} outside [{lo}, {hi}]"
    )
  invisible(!any(bad))
}

# Internal validation shared by statistical summaries.

.validate_elapsed_time <- function(x, name, allow_na = TRUE) {
  numeric_or_missing <- is.numeric(x) || (allow_na && is.logical(x) && all(is.na(x)))
  if (!numeric_or_missing || any(!is.na(x) & (!is.finite(x) | x < 0)) ||
      (!allow_na && anyNA(x))) {
    cli::cli_abort("{.arg {name}} must contain nonnegative finite elapsed times{if (allow_na) ' or NA' else ' with no missing values'}.")
  }
  invisible(x)
}

.validate_window <- function(x, name) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) ||
      !is.finite(x) || x < 0) {
    cli::cli_abort("{.arg {name}} must be one finite nonnegative number.")
  }
  invisible(x)
}

.validate_n_boot <- function(n_boot, name = "n_bootstrap") {
  if (!is.numeric(n_boot) || length(n_boot) != 1L || is.na(n_boot) ||
      !is.finite(n_boot) || n_boot < 0 || n_boot != floor(n_boot) ||
      n_boot > .Machine$integer.max) {
    cli::cli_abort("{.arg {name}} must be one nonnegative integer; use 0 to omit bootstrap intervals.")
  }
  invisible(n_boot)
}

.validate_binary <- function(x, name, allow_na = FALSE) {
  if (!(is.numeric(x) || is.logical(x)) ||
      any(!is.na(x) & !(x %in% c(0, 1))) || (!allow_na && anyNA(x))) {
    cli::cli_abort("{.arg {name}} must contain binary 0/1 indicators{if (allow_na) ' or NA' else ' with no missing values'}.")
  }
  invisible(x)
}

.validate_rate <- function(x, name, allow_na = TRUE) {
  numeric_or_missing <- is.numeric(x) || (allow_na && is.logical(x) && all(is.na(x)))
  if (!numeric_or_missing || any(!is.na(x) & (!is.finite(x) | x < 0 | x > 1)) ||
      (!allow_na && anyNA(x))) {
    cli::cli_abort("{.arg {name}} must contain proportions between 0 and 1{if (allow_na) ' or NA' else ' with no missing values'}.")
  }
  invisible(x)
}
