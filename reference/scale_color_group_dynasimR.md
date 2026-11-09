# Colour scale for entity group

Applies dynasimR group colours (`A`/`B`/`C`) to a ggplot2 `color`
aesthetic.

## Usage

``` r
scale_color_group_dynasimR(...)
```

## Arguments

- ...:

  Arguments passed to
  [`ggplot2::scale_color_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html).

## Value

A ggplot2 scale object.

## Examples

``` r
library(ggplot2)
d <- data.frame(x = 1:3, y = 3:1, group = c("A", "B", "C"))
ggplot(d, aes(x, y, color = group)) +
  geom_point(size = 3) +
  scale_color_group_dynasimR()
```
