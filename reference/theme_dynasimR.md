# ggplot2 theme for dynasimR figures

A minimalist ggplot2 theme tuned for publication-quality single and
double-column output at 11 pt base size.

## Usage

``` r
theme_dynasimR(base_size = 11, legend_pos = "bottom")
```

## Arguments

- base_size:

  Numeric. Base font size. Default `11`.

- legend_pos:

  Character. Legend position. Default `"bottom"`.

## Value

A ggplot2 theme object.

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  theme_dynasimR()
```
