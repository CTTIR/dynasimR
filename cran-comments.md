## Submission

This is a new submission of dynasimR 0.2.0.

## Test environments

* local: macOS (aarch64-apple-darwin), R 4.6.1, `R CMD check --as-cran
  --no-manual` on the built tarball. The PDF manual was built locally with
  TinyTeX (TeX Live 2026) via `R CMD Rd2pdf` without errors; the check run
  itself used `--no-manual`.
* GitHub Actions (r-lib/actions v2, `--as-cran`):
  macOS-latest (release), windows-latest (release),
  ubuntu-latest (devel, release, oldrel-1) and an informational
  ubuntu-latest (oldrel-3) row.

## R CMD check results

0 errors | 0 warnings | 1 note

* checking CRAN incoming feasibility ... NOTE
  Maintainer: 'R. Heller <raban.heller@uni-ulm.de>'
  New submission

  This is the first submission of the package.

## Notes for the CRAN team

* All examples run and write only to `tempfile()` paths. `launch_app()`
  starts a 'shiny' application and is therefore only run when
  `interactive()` is `TRUE`.
* Tests that need optional packages are skipped when those packages are not
  installed.
