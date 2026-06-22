# Load the package-bundled example dataset

Convenience wrapper around
[`read_simulation()`](https://cttir.github.io/dynasimR/reference/read_simulation.md)
pointing at the CSVs shipped in `inst/extdata/`.

## Usage

``` r
load_example_data()
```

## Value

A `dynasimR_data` object.

## Examples

``` r
sim <- load_example_data()
print(sim)
#> 
#> ── dynasimR_data ───────────────────────────────────────────────────────────────
#> • Scenarios: 4
#> • Profile: "Profile_A"
#> • Summary rows: 200
#> • Entity events: 16000
#> • Loaded: "2026-06-22 12:21"
#> • Path: /home/runner/work/_temp/Library/dynasimR/extdata
```
