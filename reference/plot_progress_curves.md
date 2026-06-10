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

  Logical. Show 95% CI ribbon. Default `TRUE`.

## Value

A ggplot2 object.
