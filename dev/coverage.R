# Run from any directory with Rscript /path/to/dynasimR/dev/coverage.R.
script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
root <- dirname(dirname(normalizePath(script, mustWork = TRUE)))
setwd(root)
if (!requireNamespace("covr", quietly = TRUE)) stop("Install developer package covr.")
cov <- covr::package_coverage(path = root, quiet = TRUE)
cat("Coverage:", round(covr::percent_coverage(cov), 1), "%\n")
