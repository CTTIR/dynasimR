# Fill `[XX_*]` placeholders in a LaTeX manuscript

Substitutes `[XX_*]` placeholders in a LaTeX source file with
automatically computed simulation statistics. The mapping from
placeholder to computation is assembled inside this function from
[`policy_effect()`](https://cttir.github.io/dynasimR/reference/policy_effect.md),
[`al_efficiency()`](https://cttir.github.io/dynasimR/reference/al_efficiency.md)
and
[`compute_compliance_index()`](https://cttir.github.io/dynasimR/reference/compute_compliance_index.md).

## Usage

``` r
fill_placeholders(
  sim_data,
  tex_file,
  output_file = NULL,
  dry_run = FALSE,
  policy_a_scenario = "A-S08",
  policy_b_scenario = "A-S07",
  baseline_scenario = "A-S00",
  overwrite = FALSE
)
```

## Arguments

- sim_data:

  A `dynasimR_data` object.

- tex_file:

  Character. Path to the LaTeX source file.

- output_file:

  Character. Output path; default appends `_filled` before `.tex` (case
  insensitive), or `_filled.tex` to a filename without that extension.
  The source is never overwritten.

- dry_run:

  Logical. If `TRUE`, print replacements but do not write a file.
  Default `FALSE`.

- policy_a_scenario:

  Character. Policy A scenario ID. Default `"A-S08"`.

- policy_b_scenario:

  Character. Policy B scenario ID. Default `"A-S07"`.

- baseline_scenario:

  Character. Baseline scenario ID. Default `"A-S00"`.

- overwrite:

  Logical. Allow replacement of an existing output file. Default
  `FALSE`. This never permits overwriting the source manuscript.

## Value

Named character vector of the replacements (invisibly).

## Details

Policy event differences and their confidence limits use the signed
A-minus-B convention, in percentage points. A write is refused if the
manuscript requests unknown placeholders or unavailable/non-finite
statistics. `dry_run = TRUE` reports these without writing a file.

## Examples

``` r
sim <- load_example_data()
tex <- tempfile(fileext = ".tex")
writeLines(c("Baseline event rate: [XX_EVENT_BASELINE]\\%.",
             "Compliance under policy A: [XX_COMPLIANCE_A]."), tex)
fill_placeholders(sim, tex, dry_run = TRUE)
#> 
#> ── Placeholder substitutions ──
#> 
#> • `[XX_POLICY_DELTA_EVENT]` -> "-7.4"
#> • `[XX_POLICY_DELTA_CI_LO]` -> "-9.1"
#> • `[XX_POLICY_DELTA_CI_HI]` -> "-5.5"
#> • `[XX_COMPLIANCE_A]` -> "0.542"
#> • `[XX_COMPLIANCE_B]` -> "0.276"
#> • `[XX_OPTIMAL_AL]` -> NA
#> • `[XX_EVENT_BASELINE]` -> "34.1"
#> • `[XX_EVENT_BEST]` -> "22.3"
#> ℹ Dry run: no file written.
out <- fill_placeholders(sim, tex)
#> 
#> ── Placeholder substitutions ──
#> 
#> • `[XX_POLICY_DELTA_EVENT]` -> "-7.4"
#> • `[XX_POLICY_DELTA_CI_LO]` -> "-9"
#> • `[XX_POLICY_DELTA_CI_HI]` -> "-5.5"
#> • `[XX_COMPLIANCE_A]` -> "0.542"
#> • `[XX_COMPLIANCE_B]` -> "0.276"
#> • `[XX_OPTIMAL_AL]` -> NA
#> • `[XX_EVENT_BASELINE]` -> "34.1"
#> • `[XX_EVENT_BEST]` -> "22.3"
#> ✔ Filled: /tmp/RtmplR7HTu/file18b569167f43_filled.tex
readLines(sub("\\.tex$", "_filled.tex", tex))
#> [1] "Baseline event rate: 34.1\\%."     "Compliance under policy A: 0.542."
unlink(c(tex, sub("\\.tex$", "_filled.tex", tex)))
```
