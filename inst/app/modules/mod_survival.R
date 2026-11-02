## Time-to-event module -------------------------------------------------

mod_survival_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      shinydashboard::box(
        title = "Controls", width = 4, status = "info",
        solidHeader = TRUE,
        shinyWidgets::pickerInput(ns("scenarios"), "Scenarios",
          choices = NULL, multiple = TRUE,
          options = list(`actions-box` = TRUE)),
        selectInput(ns("endpoint"), "Endpoint",
          choices = c("stage2", "overall", "service"),
          selected = "stage2"),
        checkboxInput(ns("stratify_group"),
          "Stratify by group", FALSE),
        checkboxInput(ns("show_ci"),  "Show CI ribbon",  TRUE),
        checkboxInput(ns("show_pval"), "Show log-rank p", TRUE)
      ),
      shinydashboard::box(
        title = "Kaplan-Meier",
        status = "primary", solidHeader = TRUE, width = 8,
        plotOutput(ns("km_plot"), height = 440)
      )
    ),
    fluidRow(
      shinydashboard::box(
        title = "Cox forest plot",
        status = "primary", solidHeader = TRUE, width = 12,
        plotOutput(ns("forest_plot"), height = 360)
      )
    )
  )
}

mod_survival_server <- function(id, sim_data) {
  moduleServer(id, function(input, output, session) {

    observe({
      sc <- unique(sim_data$entities$scenario)
      shinyWidgets::updatePickerInput(session, "scenarios",
        choices = sc, selected = sc)
    })

    km_result <- reactive({
      req(input$scenarios)
      dynasimR::km_estimate(
        sim_data,
        scenarios   = input$scenarios,
        endpoint    = input$endpoint,
        stratify_by = if (input$stratify_group)
          c("scenario", "group") else "scenario"
      )
    })

    output$km_plot <- renderPlot({
      dynasimR::plot_km(km_result(),
        show_ci = input$show_ci,
        show_pval = input$show_pval)
    })

    cox_result <- reactive({
      req(input$scenarios)
      if (length(unique(input$scenarios)) < 2L) return(NULL)
      selected <- sim_data$entities |>
        dplyr::filter(.data$scenario %in% input$scenarios)
      tryCatch(
        dynasimR::cox_model(
          selected,
          endpoint = input$endpoint,
          reference_scenario = input$scenarios[1]
        ),
        error = function(e) NULL
      )
    })

    output$forest_plot <- renderPlot({
      cr <- cox_result()
      if (is.null(cr)) {
        plot.new()
        text(0.5, 0.5, if (length(input$scenarios) < 2L)
          "Select at least two scenarios for a Cox comparison" else
            "Cox model failed; try different scenarios")
      } else {
        dynasimR::plot_forest(cr)
      }
    })
  })
}
