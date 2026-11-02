# Run from any directory with Rscript /path/to/dynasimR/dev/dep_check.R.
script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
root <- dirname(dirname(normalizePath(script, mustWork = TRUE)))
setwd(root)
desc <- read.dcf("DESCRIPTION")
packages <- function(field) {
  if (!field %in% colnames(desc)) return(character())
  trimws(gsub("\\s*\\([^)]*\\)", "", strsplit(desc[1, field], ",")[[1]]))
}
declared <- unique(c(packages("Imports"), packages("Suggests"), packages("Depends"), "base"))
sources <- list.files("R", pattern = "\\.R$", full.names = TRUE)
used <- character()
visit <- function(expr) {
  if (is.call(expr) && (identical(expr[[1]], as.name("::")) ||
                       identical(expr[[1]], as.name(":::"))))
    used <<- c(used, as.character(expr[[2]]))
  if (is.recursive(expr)) for (i in seq_along(expr))
    if (!identical(expr[[i]], quote(expr = ))) visit(expr[[i]])
}
for (file in sources) visit(parse(file))
used <- sort(unique(used))
cat("Namespaces used:\n", paste(used, collapse = "\n"), "\n", sep = "")
missing <- setdiff(used, declared)
if (length(missing)) stop("Undeclared namespaces: ", paste(missing, collapse = ", "))
