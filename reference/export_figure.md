# Export a ggplot in publication-ready format

Writes a ggplot2 object to PDF/SVG/PNG/TIFF/EPS at the specified
physical dimensions (in millimetres) and resolution.

## Usage

``` r
export_figure(
  plot,
  filename,
  width_mm = 174,
  height_mm = 120,
  dpi = 300,
  format = NULL
)
```

## Arguments

- plot:

  A ggplot2 object.

- filename:

  Character. Output path (extension determines format unless `format` is
  supplied).

- width_mm:

  Numeric. Width in mm. `88` approximates one column and `174` two
  columns; check the target journal's dimensions. Default `174`.

- height_mm:

  Numeric. Height in mm. Default `120`.

- dpi:

  Integer. Raster resolution. Default `300`.

- format:

  Character. Optional explicit format (`pdf`, `svg`, `png`, `tiff`, or
  `eps`), useful for extensionless download staging paths.

## Value

Invisibly, the filename.

## Details

SVG uses R's Cairo graphics device. Its runtime libraries must be
available; macOS builds of R linked to X11, including CRAN binaries, may
require XQuartz. Install it and restart R if SVG reports missing
X11/Cairo libraries. Exports are staged and checked for nonempty output
before an existing file is replaced. Device errors and warnings remain
visible.

## Examples

``` r
p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, hp)) +
  ggplot2::geom_point()
out <- tempfile(fileext = ".pdf")
export_figure(p, out, width_mm = 120, height_mm = 90)
#> ✔ Figure saved: /tmp/RtmpqAQwFg/file186e6f20d6ff.pdf (120x90 mm)
file.exists(out)
#> [1] TRUE
unlink(out)
```
