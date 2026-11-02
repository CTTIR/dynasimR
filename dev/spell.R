# Run from any directory with Rscript /path/to/dynasimR/dev/spell.R.
script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
root <- dirname(dirname(normalizePath(script, mustWork = TRUE)))
setwd(root)
if (!requireNamespace("spelling", quietly = TRUE)) stop("Install developer package spelling.")
result <- spelling::spell_check_package(root)
print(result)
if (nrow(result)) quit(status = 1L)
