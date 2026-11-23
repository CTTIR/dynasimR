## Autonomy module ------------------------------------------------------

mod_autonomy_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      shinydashboard::box(
        title = "Controls", status = "info",
        solidHeader = TRUE, width = 4,
        sliderInput(ns("compliance_threshold"),
          "Compliance threshold",
          min = 0.5, max = 1, value = 0.8, step = 0.05),
        checkboxInput(ns("highlight"),
          "Highlight optimal AL", TRUE),
        textOutput(ns("availability"))
      ),
      shinydashboard::box(
        title = "Trade-off plot", status = "primary",
        solidHeader = TRUE, width = 8,
        plotly::plotlyOutput(ns("tradeoff_plot"), height = 440)
      )
    ),
    fluidRow(
      shinydashboard::box(
        title = "Trade-off table", status = "info",
        solidHeader = TRUE, width = 12,
        DT::DTOutput(ns("tradeoff_tbl"))
      )
    )
  )
}

mod_autonomy_server <- function(id, sim_data) {
  moduleServer(id, function(input, output, session) {

    al_res <- reactive({
      tryCatch(
        dynasimR::al_efficiency(sim_data,
          compliance_threshold = input$compliance_threshold),
        error = function(e) NULL
      )
    })

    output$availability <- renderText({
      al <- al_res()
      if (is.null(al))
        return("Autonomy analysis is unavailable for this dataset. It requires autonomy levels and compliance/event outcomes.")
      omitted <- al$params$omitted_scenarios
      if (length(omitted))
        paste0("Scenarios of the default autonomy sweep that are not in this dataset: ",
               paste(omitted, collapse = ", "),
               ". Use al_efficiency(al_scenarios = ...) in R to map other scenarios.")
      else ""
    })

    output$tradeoff_plot <- plotly::renderPlotly({
      al <- al_res()
      if (is.null(al)) return(plotly::plotly_empty())
      # Static label offsets and the bottom legend do not survive the
      # conversion: rely on hover text and place the legend above the plot.
      p <- dynasimR::plot_al_tradeoff(al,
        label_points      = FALSE,
        highlight_optimal = input$highlight)
      plotly::ggplotly(p) |>
        plotly::layout(
          legend = list(orientation = "h", x = 0, y = 1.02,
                         xanchor = "left", yanchor = "bottom"),
          margin = list(t = 70, b = 55)
        )
    })

    output$tradeoff_tbl <- DT::renderDT({
      al <- al_res()
      if (is.null(al)) return(NULL)
      utils::getFromNamespace(".app_rounded_table", "dynasimR")(al$tradeoff_table,
        options = list(pageLength = 10, scrollX = TRUE))
    })
  })
}
