# Validate a dynasimR_data object

Checks required columns, nonmissing scenario/replication identifiers,
numeric types, finite observed values and bounded rates. Entity and
time-series scenario/replication pairs must occur in the summary table.
Missing measurements are allowed; analysis functions document their
treatment. Data values are not modified.

## Usage

``` r
validate_dynasimR_data(x, strict = FALSE)
```

## Arguments

- x:

  A `dynasimR_data` object (list with `summary`, `entities`,
  `timeseries`).

- strict:

  Logical. If `TRUE`, any validation issue aborts; if `FALSE` (default),
  issues produce warnings and the function still returns `x`.

## Value

The input `x`, invisibly, with current issues in the `validation_issues`
attribute, or no such attribute when valid.

## Examples

``` r
sim <- load_example_data()
checked <- validate_dynasimR_data(sim)
attr(checked, "validation_issues")
#> NULL
```
