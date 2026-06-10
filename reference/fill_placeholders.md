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
  baseline_scenario = "A-S00"
)
```

## Arguments

- sim_data:

  A `dynasimR_data` object.

- tex_file:

  Character. Path to the LaTeX source file.

- output_file:

  Character. Output path; default appends `_filled` before `.tex`.

- dry_run:

  Logical. If `TRUE`, print replacements but do not write a file.
  Default `FALSE`.

- policy_a_scenario:

  Character. Policy A scenario ID. Default `"A-S08"`.

- policy_b_scenario:

  Character. Policy B scenario ID. Default `"A-S07"`.

- baseline_scenario:

  Character. Baseline scenario ID. Default `"A-S00"`.

## Value

Named character vector of the replacements (invisibly).
