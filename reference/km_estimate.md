# Kaplan-Meier estimator for simulation data

Estimates survival functions from simulated entity outcomes. Supports
several endpoints for both output profiles.

## Usage

``` r
km_estimate(
  data,
  scenarios = NULL,
  endpoint = c("stage2", "overall", "service", "regression", "completion", "phase_c"),
  stratify_by = "scenario",
  ci_method = "log",
  n_bootstrap = 0,
  seed = 42
)
```

## Arguments

- data:

  A `dynasimR_data` object or a tibble/data.frame containing
  entity-level columns. Endpoint times must be nonnegative finite
  observed event or censoring times, with binary 0/1 event flags.
  Missing times, flags or strata are rejected, not silently omitted.

- scenarios:

  Character vector. Restrict to these scenario IDs. Default `NULL` =
  all.

- endpoint:

  Character. One of `"stage2"`, `"overall"`, `"service"`,
  `"regression"`, `"completion"`, `"phase_c"`. The latter three are
  Profile-B-only endpoints.

- stratify_by:

  Character vector. Strata variables, e.g. `"scenario"` or
  `c("scenario", "group")`. Use
  [`character()`](https://rdrr.io/r/base/character.html) for a pooled
  curve. A log-rank p-value is unavailable for one stratum or when no
  events were observed.

- ci_method:

  Character. Passed to
  [`survival::survfit()`](https://rdrr.io/pkg/survival/man/survfit.html)
  as `conf.type`. Default `"log"`.

- n_bootstrap:

  Integer. Bootstrap replicates for pointwise 95% percentile bands,
  resampling entities within each stratum. `0` omits bootstrap bands
  (default). Entities are assumed independent; this does not account for
  dependence within simulation replications.

- seed:

  Integer. RNG seed for bootstrap. Default `42`; a supplied seed
  preserves the caller's RNG state. `NULL` uses the current RNG.

## Value

An S3 object of class `dynasimR_km` (list) with slots `fit`, `tidy`,
`logrank`, `median_survival`, `boot_ci` and `params`. `boot_ci` contains
`strata`, `time`, `estimate`, `conf.low`, `conf.high` and successful
replicate count `n_boot`, evaluated at time zero and the original
observed times of each stratum. Bands are unavailable for a stratum with
fewer than two entities. `tidy` retains the analytic intervals selected
by `ci_method`.

## Examples

``` r
if (FALSE) { # \dontrun{
sim <- load_example_data()
km <- km_estimate(sim, endpoint = "stage2",
                  stratify_by = "scenario")
print(km)
plot_km(km)
} # }
```
