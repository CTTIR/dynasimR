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
      if (is.null(al_res()))
        "Autonomy analysis is unavailable for this dataset. It requires autonomy levels and compliance/event outcomes." else ""
    })

    output$tradeoff_plot <- plotly::renderPlotly({
      al <- al_res()
      if (is.null(al)) return(plotly::plotly_empty())
      p <- dynasimR::plot_al_tradeoff(al,
        highlight_optimal = input$highlight)
      plotly::ggplotly(p)
    })

    output$tradeoff_tbl <- DT::renderDT({
      al <- al_res()
      if (is.null(al)) return(NULL)
      DT::datatable(al$tradeoff_table,
        options = list(pageLength = 10))
    })
  })
}
