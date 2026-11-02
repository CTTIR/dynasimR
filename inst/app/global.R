## Global state shared between ui.R and server.R

suppressPackageStartupMessages({
  library(dynasimR)
  library(shiny)
  library(shinydashboard)
  library(shinyWidgets)
  library(plotly)
  library(DT)
  library(dplyr)
  library(ggplot2)
})

# Data path set by dynasimR::launch_app(), or NULL for example data
.data_dir <- getOption("dynasimR.data_dir", default = NULL)

SIM_DATA <- if (!is.null(.data_dir)) {
  dynasimR::read_simulation(.data_dir, verbose = FALSE)
} else {
  dynasimR::load_example_data()
}

APP_PROFILE <- utils::getFromNamespace(".dashboard_profile", "dynasimR")(SIM_DATA)

SCENARIO_META <- SIM_DATA$metadata
COLORS        <- dynasimR::dynasimR_colors()

AVAILABLE_SCENARIOS <- unique(SIM_DATA$summary$scenario)

scenario_choices <- function(scenarios = AVAILABLE_SCENARIOS) {
  sc <- SCENARIO_META |>
    dplyr::filter(.data$id %in% scenarios)
  if (nrow(sc) == 0 || !"label" %in% names(sc))
    return(setNames(scenarios, scenarios))
  setNames(sc$id, paste0(sc$id, " - ", sc$label))
}

# Policy A / Policy B defaults depending on which profile is loaded
.is_profile_b <- identical(APP_PROFILE, "Profile_B")
DEFAULT_POLICY_A <- if (.is_profile_b) "B-S19" else "A-S08"
DEFAULT_POLICY_B <- if (.is_profile_b) "B-S00" else "A-S07"
