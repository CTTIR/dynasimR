# Run from any directory with Rscript /path/to/dynasimR/dev/doc_and_check.R.
script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
root <- dirname(dirname(normalizePath(script, mustWork = TRUE)))
setwd(root)
needed <- c("roxygen2", "rcmdcheck")
missing <- needed[!vapply(needed, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Install developer packages: ", paste(missing, collapse = ", "))
expected <- read.dcf("DESCRIPTION")[[1, "Config/roxygen2/version"]]
if (as.character(packageVersion("roxygen2")) != expected)
  stop("Documentation requires roxygen2 ", expected)
roxygen2::roxygenise(root)
check_dir <- file.path(root, ".checks", format(Sys.time(), "%Y%m%d-%H%M%S"))
dir.create(check_dir, recursive = TRUE)
# rcmdcheck builds a source archive including vignettes, then checks it.
# Notes also fail this release gate; inspect and resolve them explicitly.
result <- rcmdcheck::rcmdcheck(path = root, args = "--as-cran",
  check_dir = check_dir, error_on = "note")
print(result)
