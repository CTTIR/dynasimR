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
  on the loaded tables. Default `TRUE`.

- verbose:

  Logical. Print progress messages. Default `TRUE`.

## Value

An S3 object of class `dynasimR_data` (a list) with slots `summary`,
`entities`, `timeseries`, `metadata` and `load_info`.

## Examples

``` r
if (FALSE) { # \dontrun{
sim <- read_simulation("data/raw/")
sim <- read_simulation("data/raw/",
                       scenarios = c("A-S00", "A-S07", "A-S08"))
sim <- read_simulation(system.file("extdata", package = "dynasimR"))
} # }
```
