# Export a tibble as a publication-quality LaTeX table

Produces a `booktabs`-style table using `\\botrule` instead of
`\\bottomrule`. Cells, column names, captions and notes are treated as
literal text and escaped once. Notes use a `threeparttable` environment.
The document needs `booktabs` and, for notes, `threeparttable`; outside
a publisher class defining `\\botrule`, add
`\\providecommand{\\botrule}{\\bottomrule}` to the preamble.

## Usage

``` r
export_latex_table(
  data,
  filename,
  caption,
  label,
  note = NULL,
  digits = 3,
  col_format = NULL
)
```

## Arguments

- data:

  A tibble/data.frame.

- filename:

  Character. Output `.tex` path.

- caption:

  Character. Table caption.

- label:

  Character. LaTeX label (without the `tab:` prefix; it will be added).
  Use letters, digits, colons, periods, underscores and hyphens,
  starting with a letter or digit.

- note:

  Character. Optional footnote text.

- digits:

  Integer. Digits for numeric columns. Default `3`.

- col_format:

  Character vector. Column alignment spec (e.g. `c("l", "r", "r")`).
  Default `NULL` picks `"l"` for the first column and `"r"` for the
  rest.

## Value

The LaTeX source, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
export_latex_table(head(iris), "iris.tex",
                   caption = "First rows of iris.",
                   label   = "iris")
} # }
```
