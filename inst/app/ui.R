## ui.R - dynasimR Shiny dashboard

module_dir <- file.path("modules")
for (m in list.files(module_dir, pattern = "\\.R$",
                     full.names = TRUE))
  source(m, local = TRUE)

header <- shinydashboard::dashboardHeader(
  title = "dynasimR"
)

sidebar <- shinydashboard::dashboardSidebar(
  shiny::div(style = "padding:12px;text-align:center;",
    utils::getFromNamespace(".cttir_brand_logo", "dynasimR")(96, mode = "dark")),
  shinydashboard::sidebarMenu(
    shinydashboard::menuItem("Overview",
      tabName = "overview",   icon = icon("gauge")),
    shinydashboard::menuItem("Map",
      tabName = "map",        icon = icon("map")),
    shinydashboard::menuItem("Time-to-event",
      tabName = "survival",   icon = icon("chart-line")),
    shinydashboard::menuItem("Comparison",
      tabName = "comparison", icon = icon("table")),
    shinydashboard::menuItem("Policy",
      tabName = "policy",     icon = icon("scale-balanced")),
    shinydashboard::menuItem("Autonomy",
      tabName = "autonomy",   icon = icon("robot")),
    shinydashboard::menuItem("Export",
      tabName = "export",     icon = icon("download"))
  )
)

profile_b_notice <- function(analysis) {
  shinydashboard::box(
    title = analysis, status = "info", solidHeader = TRUE, width = 12,
    p(paste0(analysis, " is not available for Profile B in this dashboard.")),
    p("Use Overview and Comparison for progress and completion summaries, and Export for a summary table. Additional Profile B analyses are available through the R package.")
  )
}

body <- shinydashboard::dashboardBody(
  shinydashboard::tabItems(
    shinydashboard::tabItem(tabName = "overview",
      mod_overview_ui("overview", profile_b = .is_profile_b)),
    shinydashboard::tabItem(tabName = "map",
      if (.is_profile_b) profile_b_notice("Map") else mod_map_ui("map")),
    shinydashboard::tabItem(tabName = "survival",
      if (.is_profile_b) profile_b_notice("Time-to-event") else
        mod_survival_ui("survival")),
    shinydashboard::tabItem(tabName = "comparison",
      mod_comparison_ui("comparison")),
    shinydashboard::tabItem(tabName = "policy",
      if (.is_profile_b) profile_b_notice("Policy analysis") else
        mod_policy_ui("policy")),
    shinydashboard::tabItem(tabName = "autonomy",
      if (.is_profile_b) profile_b_notice("Autonomy analysis") else
        mod_autonomy_ui("autonomy")),
    shinydashboard::tabItem(tabName = "export",
      mod_export_ui("export", profile_b = .is_profile_b))
  )
)

shinydashboard::dashboardPage(header, sidebar, body,
  title = "dynasimR dashboard")
