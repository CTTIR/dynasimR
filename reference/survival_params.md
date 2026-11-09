# Example Weibull event-time parameters by priority category

Illustrative Weibull shape and scale parameters for modelling
time-to-event trajectories, stratified by priority category (P1-P4).
Values are provided as a starting point and can be replaced by
domain-specific values for a particular application.

## Usage

``` r
survival_params
```

## Format

A tibble with 4 rows and the following columns:

- category:

  Character. Priority category (`"P1"`..`"P4"`).

- k:

  Numeric. Weibull shape parameter.

- lambda:

  Numeric. Weibull scale parameter (time units).

- source:

  Character. Source note.

## Source

Package example data.
