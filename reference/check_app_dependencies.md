# Check availability of Shiny-app dependencies

Inspects the `Suggests:` packages required by the embedded Shiny
dashboard, including table export, and prints which ones are installed.
This function reports an installation command; it does not install
packages.

## Usage

``` r
check_app_dependencies()
```

## Value

A tibble with columns `package`, `installed`, `version`, invisibly.

## Examples

``` r
check_app_dependencies()
#> ✔ All Shiny-app dependencies available.
```
