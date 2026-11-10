# Load simulation outputs into the dynasimR standard format

Reads CSV outputs from any discrete-event or agent-based simulation
framework that follows the dynasimR file-naming convention and validates
them against the dynasimR data schema. Returns a structured S3 object of
class `dynasimR_data`.

## Usage

``` r
read_simulation(data_dir, scenarios = NULL, validate = TRUE, verbose = TRUE)
```

## Arguments

- data_dir:

  Character. Path to the directory containing simulation outputs. Files
  are expected to follow the pattern `{scenario_id}_summary.csv`,
  `{scenario_id}_entities.csv` and (optionally)
  `{scenario_id}_timeseries.csv`.

- scenarios:

  Character vector. Scenario IDs to load. Default `NULL` loads every
  scenario found in `data_dir`.

- validate:

  Logical. Run
  [`validate_dynasimR_data()`](https://cttir.github.io/dynasimR/reference/validate_dynasimR_data.md)
  on the loaded tables. Default `TRUE`. Requires nonempty summary and
  entity files, matching scenario IDs and valid schemas. `FALSE`
  bypasses those checks for inspection of incomplete output.

- verbose:

  Logical. Print progress messages. Default `TRUE`.

## Value

An S3 object of class `dynasimR_data` (a list) with slots `summary`,
`entities`, `timeseries`, `metadata` and `load_info`.

## Details

An optional `scenario_metadata.csv` uses one unique `id` per scenario.
Its columns are joined without suffixes; conflicts with nonmissing table
values are errors when `validate = TRUE`. With validation disabled,
existing table values take precedence. The bundled scenario settings are
used only for the package example directory, with local metadata taking
precedence over bundled descriptions. External files never inherit
example settings merely by sharing an ID. Each row retains its
scenario's `profile_type`; `load_info$profile_type` is `"mixed"` when
the loaded scenarios use different profiles.

## Examples

``` r
example_dir <- system.file("extdata", package = "dynasimR")
sim <- read_simulation(example_dir)
#> ℹ Loading 4 scenarios from /home/runner/work/_temp/Library/dynasimR/extdata
#> ✔ Loaded 200 summary rows, 
sim
#> 
#> ── dynasimR_data ───────────────────────────────────────────────────────────────
#> • Scenarios: 4
#> • Profile: "Profile_A"
#> • Summary rows: 200
#> • Entity events: 16000
#> • Loaded: "2026-11-10 18:17"
#> • Path: /home/runner/work/_temp/Library/dynasimR/extdata
sim_sub <- read_simulation(example_dir,
                           scenarios = c("A-S00", "A-S07", "A-S08"),
                           verbose = FALSE)
```
