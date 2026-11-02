## Comparison module ----------------------------------------------------

mod_comparison_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      shinydashboard::box(
        title = "Controls", status = "info", solidHeader = TRUE,
        width = 4,
        shinyWidgets::pickerInput(ns("metrics"), "Metrics",
          choices  = NULL, multiple = TRUE,
          options = list(`actions-box` = TRUE)),
        shinyWidgets::pickerInput(ns("scenarios"), "Scenarios",
          choices  = NULL, multiple = TRUE,
          options = list(`actions-box` = TRUE))
      ),
      shinydashboard::box(
        title = "Heatmap", status = "primary",
        solidHeader = TRUE, width = 8,
        p("Each cell shows a scenario median in that metric's input units; colours use a shared numeric scale."),
        plotOutput(ns("heatmap"), height = 480)
      )
    )
  )
}

mod_comparison_server <- function(id, sim_data) {
  moduleServer(id, function(input, output, session) {

    observe({
      numeric_cols <- names(sim_data$summary)[
        vapply(sim_data$summary, is.numeric, logical(1))]
      default_metrics <- intersect(
        c("event_rate", "compliance_index", "progress_gain",
          "completion_rate"), numeric_cols)
      shinyWidgets::updatePickerInput(session, "metrics",
        choices  = numeric_cols,
        selected = if (length(default_metrics) > 0)
          default_metrics else numeric_cols[1])

      sc <- unique(sim_data$summary$scenario)
      shinyWidgets::updatePickerInput(session, "scenarios",
        choices = sc, selected = sc)
    })

    output$heatmap <- renderPlot({
      req(input$metrics, input$scenarios)
      dynasimR::plot_scenario_heatmap(
        sim_data,
        scenarios = input$scenarios,
        metrics   = input$metrics
      )
    })
  })
}
