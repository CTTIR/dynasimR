# Progress-score trajectory plot (Profile B)

Plots longitudinal progress-score trajectories from the output of
[`progress_trajectory()`](https://cttir.github.io/dynasimR/reference/progress_trajectory.md)
(with `longitudinal = TRUE`).

## Usage

``` r
plot_progress_curves(progress_result, show_ci = TRUE)
```

## Arguments

- progress_result:

  A `dynasimR_progress` object.

- show_ci:

  Logical. Show the central 2.5–97.5 percentile range of observed
  progress scores. This is a descriptive range, not a confidence
  interval; the argument name is retained for compatibility. Default
  `TRUE`.

## Value

A ggplot2 object.

## Examples

``` r
set.seed(1)
entities <- data.frame(
  scenario           = rep(c("B-S00", "B-S01"), each = 40),
  cohort             = rep(c("early", "late"), times = 40),
  progress_start     = stats::runif(80, 40, 60),
  progress_end       = stats::runif(80, 60, 90),
  wait_days          = stats::rexp(80, 1 / 10),
  severity           = stats::runif(80),
  completion_outcome = factor(sample(c("full", "partial", "none"), 80,
                                     replace = TRUE))
)
plot_progress_curves(progress_trajectory(entities))
```
