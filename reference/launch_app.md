# Launch the dynasimR Shiny dashboard

Starts the interactive analysis app bundled with dynasimR. The app
requires simulation data; either supply a directory via `data_dir` or
leave it `NULL` to use the bundled example data. Profile B supports
progress/completion overview, comparison and summary table export. Other
dashboard analyses require Profile A. Mixed-profile directories must be
separated for dashboard use; the R loading API can still read them
together.

## Usage

``` r
launch_app(data_dir = NULL, port = 3838, launch.browser = TRUE, ...)
```

## Arguments

- data_dir:

  Character. Path to a directory of simulation outputs. Default `NULL` =
  use bundled example data.

- port:

  Integer. Port for the local server. Default `3838`.

- launch.browser:

  Logical. Open in browser. Default `TRUE`.

- ...:

  Additional arguments forwarded to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

## Value

Does not return (blocks until the app is closed).

## Examples

``` r
# Starts an interactive Shiny session; run it from an interactive R
# session.
if (interactive() && all(check_app_dependencies()$installed)) {
  launch_app()
}
```
