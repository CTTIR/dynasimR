# Maintenance audit — 31 October to 2 November 2026

Repository: CTTIR/dynasimR. Base: `076a99c0281cb199670c40759b514956bb005ef7`.
Work is isolated from the clean original checkout. No publication or submission
is authorized by this maintenance record.

## Purpose and baseline

The package promises a common analysis API for two simulation-output profiles,
a Shiny dashboard and publication exports. The important user paths are loading
one's own files, obtaining faithful descriptive/survival/policy results,
selecting the same data across dashboard analyses, and exporting usable plots,
tables and manuscript values without modifying the source manuscript.

On R 4.6.1 the unmodified source passed 217 assertions in 142 test blocks, with
no failures or skips and four ggplot2 deprecation warnings. `fresh` and
`survminer` were absent from the initial library; this is an environment fact,
not a package defect. Existing hosted checks passed on the base commit;
maintenance-branch CI has not run. A real browser baseline rendered all seven
tabs without visible/JavaScript errors and downloaded a valid 42,613-byte PDF.
This does not establish correctness of custom-data or hostile-input paths. Raw baseline and independent probe evidence
is retained in the workspace audit under `evidence/dynasimR/`.

## Confirmed findings and implementation strategy

| Priority | Evidence / impact | Locations | Repair and acceptance |
|---|---|---|---|
| Essential | Scenario text is parsed as R code; a harmless probe wrote a canary file | `write_manuscript.R` | Compare IDs as data; hostile IDs must never evaluate or alter files |
| Essential | A policy with worse event rate and compliance is described as an improvement; a requested 80% interval is labelled 95% | `policy.R` | Signed A-minus-B estimates, matching direction/confidence labels, hand-calculated adverse and null cases |
| Essential | Survival drops missing observations while reporting the original N, recodes 1/2 events, drops requested absent Cox covariates, and misreports an absent reference | `survival.R` | Explicit input/selection contracts, honest fitted N, exact covariate/reference handling, single/all-censored strata cases |
| Essential | Independent bootstrap calls produced an inverted interval [1,0]; unequal-n Cohen d uses incorrect pooling | `utils-bootstrap.R`, statistical modules | Reuse one bootstrap sample distribution per interval; correct variance pooling; deterministic regression oracles |
| Essential | Nonrecipients and negative/nonfinite elapsed times can count as timely service | `compliance.R`, `wait_gap.R`, validation | Validate times and membership in each denominator; censored and invalid cases tested |
| Essential | Input scenario mismatches and missing entity files are accepted; strict time-series validation is bypassed | `read_simulation.R`, `validate_data.R` | Check identity/completeness/type contracts and make strict validation effective |
| Everyday use | Metadata lookup is unreliable; bundled and caller metadata need clear ownership | `read_simulation.R` | Verify installed-package behavior; use caller metadata without silently injecting example labels; both profiles and external fixtures |
| Everyday use | Balanced supply/demand is reported as undersupply; stage completion can be missing despite observed binary outcomes | `spatial.R`, `entity_flow.R` | Hand-computed balanced/empty/zero-demand and stage completion cases |
| Everyday use | Selected KM and Cox views analyse different scenario sets; relative data paths fail after app startup | app modules, `launch_app.R` | Shared selected input and normalized launch path; testServer and real browser checks |
| Everyday use | Direct export callback rejects extensionless paths (compatibility risk; current Shiny PDF download passed); LaTeX notes lose backslashes and cell text is double-escaped | app export, `write_manuscript.R`, `utils-latex.R` | Explicit format, valid literal text, compiled LaTeX and real downloads |
| Everyday use | Uppercase .TEX input is overwritten by default; point estimate and interval signs disagree in placeholders | `write_manuscript.R` | Distinct output path, source hash preservation and consistent signed values |
| Release preparation | Check script has a machine-specific path and does not fail on check errors; maintainer email is a placeholder | `dev/`, DESCRIPTION | Portable fail-closed commands; reachable maintainer contact before submission |

### Milestones

1. **Faithful inputs and scientific results.** Repair the confirmed input and
   statistical defects with regression fixtures derived independently of the
   implementation. Preserve original example/source data. Both profiles must
   retain their documented units and meaning. Do not silently substitute a
   different model or treat a dropped observation as fitted.
2. **Usable dashboard and exports.** Keep selection consistent across analyses,
   treat scenario IDs and table cells as data, preserve source manuscripts, and
   exercise actual application startup, tabs and downloads. Compile and inspect
   exported LaTeX rather than relying only on string assertions.
3. **Dependable maintenance and release package.** Repair portable developer
   checks, update implementation/docs/tests together, resolve deprecations,
   build vignettes and a source archive, install into a fresh project library,
   and run the applicable package checks. Record actual external-release status.
4. **Independent review and handover.** Challenge corrected results and failure
   paths, verify source/archive correspondence and sole Git identity, retain
   evidence and give exact first-use commands. Complete all unblocked repairs.

Dependencies: statistical/input contracts precede final dashboard and report
qualification; final documentation and packaging follow completed source edits.
The strongest coherent release preserves supported analysis meaning and makes
failures explicit. A new simulation engine, speculative architectural rewrite,
full Morris trajectory redesign, additional dashboard features and scientific
validation of users' simulation models remain outside this maintenance scope.

## Release evidence and gates

Rechecked on 2 November 2026: the CRAN package index has no dynasimR entry. The public Zenodo record
and DataCite DOI endpoints return 404 for `10.5281/zenodo.21889932`; the existing
`.zenodo.json` explicitly says the record is a prepared, unpublished draft.
Preserve that draft identifier and author/ORCID provenance without presenting it as
confirmed public publication. Do not submit or publish automatically.

The placeholder `r-heller@example.org` cannot serve as the reachable maintainer
contact required by [CRAN policy](https://stat.ethz.ch/CRAN/web/packages/policies.html).
A preferred public contact has been requested; independent implementation and
validation continue while that metadata remains unresolved.

## Work and verification

### Completed implementation

- Inputs are validated per file before binding, with explicit scenario identity,
  complete file pairs and ownership of caller metadata. All 18 original files
  under `data-raw`, `data` and `inst/extdata` match the base SHA-256 values.
- Statistical repairs cover signed policy results, unequal-sample effect sizes,
  coherent bootstrap intervals, invalid/censored inputs, fitted sample counts,
  literal model predictors, binary outcome labels and autonomy reduction bands.
  A nondefault autonomy reference is now labelled correctly in the plot.
- Survival plots include time zero, genuine numbers at risk and visible
  singleton-time estimates. Progress ranges are labelled as descriptive.
  Cost-outcome plots retain their fixed-reference estimator with honest observed
  fraction labels; undefined ratios no longer acquire an arbitrary epsilon.
- Manuscript exports treat identifiers as data, protect source/output files,
  reject requested unknown/unavailable results, and escape literal LaTeX text.
  Real PDF/PNG/SVG and table exports were exercised, compiled where applicable,
  and visually inspected.
- Dashboard selection is consistent across KM/Cox. Profile B has supported
  overview/comparison/summary export and explicit messages for unavailable
  analyses. Mixed-profile dashboard input fails clearly; the R loader remains
  available for mixed data. Hostile-looking identifiers do not execute code.
- Portable developer scripts replace machine-specific paths and obsolete APIs.
  Documentation regeneration retains unrelated files; the release check fails
  on notes as well as errors/warnings. Developer negative fixtures confirm
  undeclared namespaces and a wrong documentation-generator version exit 1.
- Version 0.1.1 is prepared as an unpublished development candidate. Citation
  metadata retains the original author/ORCID. Repository-only metadata and the
  linked-worktree `.git` file are excluded from source distributions.

### Observed verification

- Baseline: 217 assertions, four deprecation warnings. Intermediate integrated
  source tests: 495 assertions, no warnings/failures/skips. Subsequent focused
  tests cover completion models, cost outcomes and plot edge cases.
- First complete `R CMD check --as-cran`: 0 errors, 0 warnings, 4 notes;
  532 assertions passed with one existing `skip_on_cran` resource test.
  Vignette rebuilds and PDF/HTML manuals passed. Three notes identified stray
  repository metadata; exclusions were repaired. The remaining incoming note
  says new submission and displays the current placeholder maintainer.
- Final `R CMD check --as-cran`: **0 errors, 0 warnings, 1 note**, with
  **532 assertions passed and one existing CRAN-specific skip**. All vignette
  rebuilds and PDF/HTML manuals passed. The remaining note is the new-submission
  incoming check displaying the placeholder maintainer. The strict developer
  script exits 1 for this note; it has not passed the final release gate.
- Full source browser journeys for both profiles passed with real downloads.
  A fresh-library installed app also started and downloaded a valid PDF.
  No browser JavaScript errors or injected identifiers were observed.
- The local pkgdown site built; seven principal pages passed browser checks,
  including local links/images and desktop/mobile visual inspection. This is
  local site evidence, not deployment to GitHub Pages.
- The final source archive contains no `.git`, `.zenodo.json`, `CITATION.cff`,
  `Rplots.pdf` or `.checks` content. Its 180 comparable source files match the
  worktree. The source-data manifest verifies all 18 original data files.

Detailed logs, test results, screenshots, rendered files and SHA-256 manifests
are retained in the workspace audit's `evidence/dynasimR/`. Original failed
attempts are retained separately from successful follow-up runs.

### First use

For a new installation, R >= 4.1 is required. From the repository checkout:

```r
install.packages(c("remotes", "xtable", "shiny", "shinydashboard",
                   "shinyWidgets", "plotly", "DT"))
remotes::install_local(".", dependencies = NA, upgrade = "never")
library(dynasimR)
sim <- load_example_data()
print(policy_effect(sim, "A-S08", "A-S07"))
plot_km(km_estimate(sim, endpoint = "stage2"))
launch_app()  # http://127.0.0.1:3838; stop with Ctrl-C in the R console
```

Use `read_simulation("/path/to/outputs")` for your files. Profile B analyses are
listed in README; mixed-profile directories must be separated for the dashboard.
LaTeX compilation requires the preamble described in the manuscript vignette.
The source-package check additionally needs Pandoc, TeX, `rcmdcheck` and
roxygen2 8.0.0. `Rscript dev/smoke_test.R` exercises both profiles; use
`Rscript dev/doc_and_check.R` for the strict source-package release gate.

### Remaining gates and deferred work

Local scientific/input/export defects identified by this audit are repaired.
Scientific qualification of a user's simulation model and dependence structure
is outside this package audit. Entity-level bootstrap intervals assume
independence; matched runs and replication clustering require an appropriate
study-specific method. Morris trajectory designs and inferential economic
acceptability analysis remain outside this release.

Before submission: supply an approved reachable maintainer email, review the
CRAN incoming note, rerun checks for the exact release commit on Linux/Windows
and supported R versions, and confirm the intended archival record. Shared
hosted lint/coverage are currently report-only and hosted R checks omit the PDF
manual; those are not substitutes for this local manual/check evidence.

The original checkout remains clean at the base commit. Maintenance changes
are isolated on `maintenance/public-readiness-20261030` and use the verified
R. Heller author and committer identity. Nothing was pushed, submitted, merged,
deployed or published. The next publication action is maintainer review of
these commits and metadata, followed by authorized hosted checks and release.


Final archive: `.checks/20261102-161658/dynasimR_0.1.1.tar.gz` (1,717,274 bytes).
SHA-256: `571c7c719dad3b710deac203352a28a173f67095b4f877227aaf14fa1b769303`.
The final check includes CRAN incoming checks and did not disable manual checks.
Actionlint passed all four local workflow files. No hosted workflow was run for
these maintenance commits.

The exact final archive installed successfully into a fresh project library.
A new R process verified that library's namespace, loaded 16,000 example entities
and 200 replication summaries, and passed the installed-package smoke workflow
for both profiles and real PDF/LaTeX exports. Existing dependency libraries were
reused; this was not a clean operating-system/dependency installation. The
installed browser smoke preceded the final documentation/packaging-only rebuild;
the app source is identical in both archives.

On this machine, the already-installed candidate can be launched with:

```sh
R_LIBS_USER="/Users/rh/Documents/GitHub/.repository-audits/cttir-public-20261030/evidence/dynasimR/final-clean-library:/Users/rh/Documents/GitHub/.repository-audits/cttir-public-20261030/tools/R-library:/Users/rh/Documents/GitHub/.repository-audit/2026-10-30-rheller-refinement/R-library" Rscript -e 'dynasimR::launch_app()'
```
