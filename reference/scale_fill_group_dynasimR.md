# Fill scale for entity group

As
[`scale_color_group_dynasimR()`](https://cttir.github.io/dynasimR/reference/scale_color_group_dynasimR.md)
but for the `fill` aesthetic.

## Usage

``` r
scale_fill_group_dynasimR(...)
```

## Arguments

- ...:

  Arguments passed to
  [`ggplot2::scale_fill_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html).

## Value

A ggplot2 scale object.

## Examples

``` r
library(ggplot2)
d <- data.frame(group = c("A", "B", "C"), n = c(4, 6, 2))
ggplot(d, aes(group, n, fill = group)) +
  geom_col() +
  scale_fill_group_dynasimR()
```
