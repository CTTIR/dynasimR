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

body <- shinydashboard::dashboardBody(
  shinydashboard::tabItems(
    shinydashboard::tabItem(tabName = "overview",
      mod_overview_ui("overview")),
    shinydashboard::tabItem(tabName = "map",
      mod_map_ui("map")),
    shinydashboard::tabItem(tabName = "survival",
      mod_survival_ui("survival")),
    shinydashboard::tabItem(tabName = "comparison",
      mod_comparison_ui("comparison")),
    shinydashboard::tabItem(tabName = "policy",
      mod_policy_ui("policy")),
    shinydashboard::tabItem(tabName = "autonomy",
      mod_autonomy_ui("autonomy")),
    shinydashboard::tabItem(tabName = "export",
      mod_export_ui("export"))
  )
)

shinydashboard::dashboardPage(header, sidebar, body,
  title = "dynasimR dashboard")
