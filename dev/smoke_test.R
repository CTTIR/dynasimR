# Run from any directory with Rscript /path/to/dynasimR/dev/smoke_test.R.
script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
root <- dirname(dirname(normalizePath(script, mustWork = TRUE)))
setwd(root)
if ("--installed" %in% commandArgs(trailingOnly = TRUE)) {
  library(dynasimR)
} else {
  if (!requireNamespace("pkgload", quietly = TRUE)) stop("Install developer package pkgload.")
  pkgload::load_all(root, quiet = TRUE)
}
set.seed(42)
sim <- load_example_data()
stopifnot(nrow(sim$entities) > 0, all(c("al", "policy") %in% names(sim$summary)))
km <- km_estimate(sim, endpoint = "stage2")
cx <- cox_model(sim, endpoint = "stage2", reference_scenario = "A-S00")
pol <- policy_effect(sim, "A-S08", "A-S07", n_bootstrap = 100)
al <- al_efficiency(sim, al_scenarios = c("0" = "A-S00", "1" = "A-S01"), n_bootstrap = 100)
ci <- compute_compliance_index(sim, by_group = FALSE, n_bootstrap = 100)
stopifnot(km$params$n_obs == nrow(sim$entities), nrow(cx$forest_data) == 3L,
          all(is.finite(pol$delta_event$median_pct_points)), nrow(ci) == 4L)

# Small synthetic Profile B fixture with hand-calculated results.
b <- data.frame(scenario = rep(c("B-S00", "B-S01"), each = 3),
  progress_start = 0, progress_end = c(1, 2, 3, 4, 5, 6),
  wait_days = c(2, 20, NA, 1, 2, 3))
progress <- progress_trajectory(b)
wait <- compute_wait_gap_index(b, n_bootstrap = 100)
stopifnot(identical(progress$summary$progress_gain_median, c(2, 5)),
          isTRUE(all.equal(wait$wgi, c(1/3, 1))))
summary_b <- data.frame(scenario = rep(c("B-S00", "B-S01"), each = 3),
  completion_rate = c(.2, .3, .4, .5, .6, .7), cost = 10:15)
group <- group_effect(summary_b, "B-S01", "B-S00", n_bootstrap = 100)
stopifnot(isTRUE(all.equal(group$delta_completion$delta_median, .3)))

out <- tempfile("dynasimR-smoke-")
dir.create(out)
plots <- list(km = plot_km(km), forest = plot_forest(cx),
              policy = plot_policy(pol), autonomy = plot_al_tradeoff(al),
              progress = plot_progress_curves(progress))
for (nm in names(plots)) export_figure(plots[[nm]], file.path(out, paste0(nm, ".pdf")))
export_latex_table(pol$effect_sizes, file.path(out, "policy.tex"),
                   caption = "Policy comparison", label = "policy")
stopifnot(all(file.info(list.files(out, full.names = TRUE))$size > 0))
cat("Profile A and B analysis, plot and export smoke checks passed.\n")
cat("Temporary outputs:", out, "\n")
