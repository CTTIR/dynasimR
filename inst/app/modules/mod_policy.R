## Policy module --------------------------------------------------------

mod_policy_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      shinydashboard::box(
        title = "Controls", status = "info",
        solidHeader = TRUE, width = 4,
        shinyWidgets::pickerInput(ns("policy_a"), "Policy A scenario",
          choices = NULL, multiple = FALSE),
        shinyWidgets::pickerInput(ns("policy_b"), "Policy B scenario",
          choices = NULL, multiple = FALSE),
        numericInput(ns("alpha"), "Alpha",
          value = 0.05, min = 0.001, max = 0.2, step = 0.01)
      ),
      shinydashboard::box(
        title = "Delta event rate", status = "primary",
        solidHeader = TRUE, width = 8,
        plotOutput(ns("policy_plot"), height = 320)
      )
    ),
    fluidRow(
      shinydashboard::box(
        title = "Auto-generated narrative",
        status = "success", solidHeader = TRUE, width = 12,
        htmlOutput(ns("narrative"))
      )
    ),
    fluidRow(
      shinydashboard::box(
        title = "Effect sizes", status = "info",
        solidHeader = TRUE, width = 6,
        DT::DTOutput(ns("effects_tbl"))
      ),
      shinydashboard::box(
        title = "Wilcoxon tests (BH-adj.)", status = "info",
        solidHeader = TRUE, width = 6,
        DT::DTOutput(ns("wilcox_tbl"))
      )
    )
  )
}

mod_policy_server <- function(id, sim_data,
                              default_policy_a = "A-S08",
                              default_policy_b = "A-S07") {
  moduleServer(id, function(input, output, session) {

    observe({
      sc <- unique(sim_data$summary$scenario)
      shinyWidgets::updatePickerInput(session, "policy_a",
        choices = sc,
        selected = if (default_policy_a %in% sc)
          default_policy_a else sc[1])
      shinyWidgets::updatePickerInput(session, "policy_b",
        choices = sc,
        selected = if (default_policy_b %in% sc)
          default_policy_b else sc[length(sc)])
    })

    pol_res <- reactive({
      req(input$policy_a, input$policy_b)
      tryCatch(
        dynasimR::policy_effect(
          sim_data,
          policy_a_scenario = input$policy_a,
          policy_b_scenario = input$policy_b,
          alpha             = input$alpha
        ),
        error = function(e) NULL
      )
    })

    output$policy_plot <- renderPlot({
      p <- pol_res()
      if (is.null(p)) {
        plot.new()
        text(0.5, 0.5, "Scenarios not available in data")
      } else {
        dynasimR::plot_policy(p)
      }
    })

    output$narrative <- renderUI({
      p <- pol_res()
      if (is.null(p)) return(tags$em("Pick two scenarios."))
      tags$p(as.character(p$narrative))
    })

    output$effects_tbl <- DT::renderDT({
      p <- pol_res()
      if (is.null(p)) return(NULL)
      DT::datatable(p$effect_sizes, options = list(dom = "t"))
    })

    output$wilcox_tbl <- DT::renderDT({
      p <- pol_res()
      if (is.null(p)) return(NULL)
      DT::datatable(p$wilcoxon_tests, options = list(dom = "t"))
    })
  })
}
