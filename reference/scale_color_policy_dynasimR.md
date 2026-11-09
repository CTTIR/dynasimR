# Colour scale for policy

Colour scale for policy

## Usage

``` r
scale_color_policy_dynasimR(...)
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
d <- data.frame(x = 1:4, y = c(1, 2, 2, 3),
                policy = rep(c("policy_a", "policy_b"), 2))
ggplot(d, aes(x, y, color = policy)) +
  geom_point(size = 3) +
  scale_color_policy_dynasimR()
```
