# Internal LaTeX helpers — not exported.

#' @keywords internal
#' @noRd
.escape_latex_text <- function(x) {
  substitutions <- c(
    "\\" = "\\textbackslash{}", "{" = "\\{", "}" = "\\}",
    "$" = "\\$", "&" = "\\&", "%" = "\\%", "_" = "\\_",
    "#" = "\\#", "^" = "\\textasciicircum{}",
    "~" = "\\textasciitilde{}", "<" = "$<$", ">" = "$>$",
    "|" = "\\textbar{}"
  )
  vapply(as.character(x), function(value) {
    if (is.na(value)) return(NA_character_)
    chars <- strsplit(value, "", fixed = TRUE)[[1]]
    escaped <- substitutions[chars]
    chars[!is.na(escaped)] <- escaped[!is.na(escaped)]
    paste0(chars, collapse = "")
  }, character(1), USE.NAMES = FALSE)
}

#' @keywords internal
#' @noRd
.escape_latex_math <- function(x) {
  if (is.null(x)) return(x)
  x <- gsub("<", "$<$", x, fixed = TRUE)
  x <- gsub(">", "$>$", x, fixed = TRUE)
  x
}

#' @keywords internal
#' @noRd
.sn_replace_bottomrule <- function(tex) {
  # sn-jnl.cls requires \botrule instead of \bottomrule
  gsub("\\\\bottomrule", "\\\\botrule", tex)
}

#' @keywords internal
#' @noRd
.format_p <- function(p) {
  if (is.na(p)) return("NA")
  if (p < 0.001) return("< 0.001")
  formatC(p, digits = 3, format = "f")
}

# "p < 0.001" or "p = 0.012": the relation is part of the statement, so a
# formatted value is never printed as a bare "p 0.012".
#' @keywords internal
#' @noRd
.format_p_text <- function(p, prefix = "p") {
  value <- .format_p(p)
  paste(prefix, if (startsWith(value, "<")) value else paste("=", value))
}
