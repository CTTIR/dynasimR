# Internal bootstrap helpers — not exported.

.with_boot_seed <- function(seed, code) {
  if (is.null(seed)) return(force(code))
  if (!is.numeric(seed) || length(seed) != 1L || is.na(seed) ||
      !is.finite(seed) || seed < 0 || seed > .Machine$integer.max ||
      seed != floor(seed)) {
    cli::cli_abort("{.arg seed} must be NULL or one nonnegative integer.")
  }
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  if (had_seed) old_seed <- get(".Random.seed", envir = .GlobalEnv)
  on.exit({
    if (had_seed) assign(".Random.seed", old_seed, envir = .GlobalEnv)
    else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE))
      rm(".Random.seed", envir = .GlobalEnv)
  }, add = TRUE)
  set.seed(seed)
  force(code)
}

.validate_boot_probs <- function(probs) {
  if (!is.numeric(probs) || length(probs) != 2L ||
      anyNA(probs) || any(!is.finite(probs)) ||
      any(probs < 0 | probs > 1) || probs[1] > probs[2]) {
    cli::cli_abort("{.arg probs} must be two ordered probabilities between 0 and 1.")
  }
}

#' @keywords internal
#' @noRd
.boot_quantile_ci <- function(x, n_boot = 1000, fun = stats::median,
                              probs = c(0.025, 0.975), seed = NULL) {
  .validate_n_boot(n_boot)
  .validate_boot_probs(probs)
  x <- x[is.finite(x)]
  if (n_boot == 0 || length(x) < 2) return(c(NA_real_, NA_real_))
  .with_boot_seed(seed, {
    reps <- vapply(seq_len(n_boot), function(i) {
      fun(x[sample.int(length(x), length(x), replace = TRUE)], na.rm = TRUE)
    }, numeric(1))
    stats::quantile(reps, probs = probs, names = FALSE, na.rm = TRUE)
  })
}

#' @keywords internal
#' @noRd
.boot_diff_ci <- function(a, b, n_boot = 1000, fun = stats::median,
                          probs = c(0.025, 0.975), seed = NULL) {
  .validate_n_boot(n_boot)
  .validate_boot_probs(probs)
  a <- a[is.finite(a)]
  b <- b[is.finite(b)]
  if (n_boot == 0 || length(a) < 2 || length(b) < 2)
    return(c(NA_real_, NA_real_))
  .with_boot_seed(seed, {
    reps <- vapply(seq_len(n_boot), function(i) {
      fa <- fun(a[sample.int(length(a), length(a), replace = TRUE)], na.rm = TRUE)
      fb <- fun(b[sample.int(length(b), length(b), replace = TRUE)], na.rm = TRUE)
      fa - fb
    }, numeric(1))
    stats::quantile(reps, probs = probs, names = FALSE, na.rm = TRUE)
  })
}
