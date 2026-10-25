# dynasimR — Dynamic Agent-Node Simulation Analysis <picture class="cttir-readme-logo"><source class="cttir-logo-dark-source" media="(prefers-color-scheme: dark)" srcset="man/figures/logo-with-name-dark.png" /><img src="man/figures/logo-with-name.png" align="right" alt="dynasimR hex logo" width="120" height="139" /></picture>

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.21889932.svg)](https://doi.org/10.5281/zenodo.21889932)

<!-- badges: start -->
[![R-CMD-check](https://github.com/CTTIR/dynasimR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/CTTIR/dynasimR/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/CTTIR/dynasimR/actions/workflows/pkgdown.yaml/badge.svg)](https://cttir.github.io/dynasimR/)
[![CRAN status](https://www.r-pkg.org/badges/version/dynasimR)](https://CRAN.R-project.org/package=dynasimR)
[![Codecov test coverage](https://codecov.io/gh/CTTIR/dynasimR/branch/main/graph/badge.svg)](https://app.codecov.io/gh/CTTIR/dynasimR?branch=main)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/dynasimR)](https://cran.r-project.org/package=dynasimR)
[![CRAN downloads total](https://cranlogs.r-pkg.org/badges/grand-total/dynasimR)](https://cran.r-project.org/package=dynasimR)
[![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

A domain-neutral analysis and visualisation layer for discrete-event,
agent-based and node-actor simulation outputs. The package is
schema-harmonised so that two output profiles (**Profile A** and
**Profile B**) can be analysed with a single API.

Typical use cases include any system in which entities (actors, nodes,
agents) move through states and interact within spatial or network
environments — for example flow analyses, state-transition studies,
resource allocation and policy comparisons.

## Installation

```r
# install.packages("remotes")
remotes::install_github("cttir/dynasimR")
```

## Quick start

```r
library(dynasimR)

# 1. Load bundled example data (or point to your own simulation outputs)
sim <- load_example_data()
# sim <- read_simulation("~/my-simulation/data/raw/")

# 2. Time-to-event analysis
km <- km_estimate(sim, endpoint = "stage2", stratify_by = "scenario")
plot_km(km, title = "Time-to-stage-2")

# 3. Policy effect (policy A vs. policy B)
pol <- policy_effect(sim, policy_a_scenario = "A-S08",
                     policy_b_scenario = "A-S07")
cat(pol$narrative)   # ready to drop into a report

# 4. Autonomy-level trade-off
al <- al_efficiency(sim)
plot_al_tradeoff(al)

# 5. Manuscript export
export_latex_table(
  data     = pol$effect_sizes,
  filename = "policy_table.tex",
  caption  = "Policy effect sizes.",
  label    = "policy"
)

# 6. Interactive Shiny dashboard
launch_app()
```

## Feature map

| Analysis goal                         | Key function                  |
|---------------------------------------|-------------------------------|
| Entity flow through processing stages | `stage_throughput()`          |
| Time-to-event stratified by scenario  | `km_estimate()`, `cox_model()`|
| Policy A vs. policy B comparison      | `policy_effect()`             |
| Autonomy-level trade-off (AL0-AL5)    | `al_efficiency()`             |
| Compliance Index                      | `compute_compliance_index()`  |
| Profile B progress trajectory         | `progress_trajectory()`       |
| Profile B wait-gap index              | `compute_wait_gap_index()`    |
| Manuscript placeholder fill           | `fill_placeholders()`         |

## Requirements

- R >= 4.1.0 (base pipe `|>` used throughout)
- Required imports: dplyr, tidyr, purrr, readr, tibble, ggplot2,
  survival, rlang, cli, glue
- Shiny app requires the `Suggests:` dependencies — install with
  `dynasimR::check_app_dependencies()`

## License

MIT (c) R. Heller

## Citation

If you use this software, please cite it as:

> Heller, R. (2026). *dynasimR: Analysis and visualisation of agent-based and discrete-event simulation output* (Version 0.1.0) [Computer software]. Zenodo. https://doi.org/10.5281/zenodo.21889932

DOI: [10.5281/zenodo.21889932](https://doi.org/10.5281/zenodo.21889932)

## Use of LLM tools

Where applicable, LLM tools were used for narrowly defined, non-authorial tasks:
copyediting, prose refinement, Markdown/LaTeX formatting, boilerplate scaffolding
(such as CI configurations and build scripts), and code refactoring. Tools included
[Chat AI](https://kisski.gwdg.de/leistungen/2-02-llm-service/), the KISSKI
(GWDG) service, and self-hosted **Mistral Small (24B, Apache-2.0)** served through
a local **vLLM architecture** on an Ubuntu Linux workstation with Intel
processors and NVIDIA GPUs. The self-hosted model ran locally, with no data sent
to third parties.

All scientific claims, methodological choices, analyses, interpretations and
conclusions remain the authors' own. Where applicable, LLM-generated material
must be reviewed and revised before inclusion, and references must be verified
against their DOI, arXiv ID or ISBN.

Local software setup: vLLM with Python/PyTorch, plus R and RStudio.

## Branding

Editable R artwork and regeneration instructions are in [tools/branding](https://github.com/CTTIR/dynasimR/blob/main/tools/branding/README.md).
