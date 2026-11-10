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
if (requireNamespace("xtable", quietly = TRUE)) {
  out <- tempfile(fileext = ".tex")
  export_latex_table(head(iris), out,
                     caption = "First rows of iris.",
                     label   = "iris")
  cat(readLines(out), sep = "\n")
  unlink(out)
}
#> ✔ LaTeX table: /tmp/RtmpXQI4Xk/file18c069ed107b.tex
#> \begin{table}[ht]
#> \centering
#> \begin{tabular}{lrrrr}
#>   \toprule
#> Sepal.Length & Sepal.Width & Petal.Length & Petal.Width & Species \\ 
#>   \midrule
#> 5.100 & 3.500 & 1.400 & 0.200 & setosa \\ 
#>   4.900 & 3.000 & 1.400 & 0.200 & setosa \\ 
#>   4.700 & 3.200 & 1.300 & 0.200 & setosa \\ 
#>   4.600 & 3.100 & 1.500 & 0.200 & setosa \\ 
#>   5.000 & 3.600 & 1.400 & 0.200 & setosa \\ 
#>   5.400 & 3.900 & 1.700 & 0.400 & setosa \\ 
#>    \botrule
#> \end{tabular}
#> \caption{First rows of iris.}
#> \label{tab:iris}
#> \end{table}
#> 
```
