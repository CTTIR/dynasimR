# Colour palette for dynasimR plots

Returns a named list of hex colours used by all `plot_*` functions.

## Usage

``` r
dynasimR_colors()
```

## Value

A named list with entries `GROUP_A`, `GROUP_B`, `GROUP_C`, `POSITIVE`,
`NEGATIVE`, `NEUTRAL`, `ACCENT`, `BG`.

## Examples

``` r
pal <- dynasimR_colors()
pal$GROUP_A
#> [1] "#1B3A6B"
```
