## Overview module ------------------------------------------------------

mod_overview_ui <- function(id, profile_b = FALSE) {
  ns <- NS(id)
  tagList(
    fluidRow(
      shinydashboard::valueBoxOutput(ns("box_scenarios"), width = 3),
      shinydashboard::valueBoxOutput(ns("box_reps"),      width = 3),
      shinydashboard::valueBoxOutput(ns("box_ent"),       width = 3),
      shinydashboard::valueBoxOutput(ns("box_profile"),   width = 3)
    ),
    fluidRow(
      shinydashboard::box(
        title = if (profile_b) "Progress-gain distribution" else
          "Event-rate distribution",
        status = "primary", solidHeader = TRUE, width = 6,
        plotly::plotlyOutput(ns("event_dist"), height = 320)
      ),
      shinydashboard::box(
        title = if (profile_b) "Completion-rate distribution" else
          "Compliance Index",
        status = "primary", solidHeader = TRUE, width = 6,
        plotly::plotlyOutput(ns("compliance_dist"), height = 320)
      )
    ),
    fluidRow(
      shinydashboard::box(
        title = "Summary table",
        status = "info", solidHeader = TRUE, width = 12,
        DT::DTOutput(ns("summary_tbl"))
      )
    )
  )
}

mod_overview_server <- function(id, sim_data) {
  moduleServer(id, function(input, output, session) {
    profile_b <- identical(sim_data$load_info$profile_type, "Profile_B")

    output$box_scenarios <- shinydashboard::renderValueBox({
      shinydashboard::valueBox(
        length(unique(sim_data$summary$scenario)),
        "Scenarios", icon = icon("layer-group"), color = "blue"
      )
    })
    output$box_reps <- shinydashboard::renderValueBox({
      shinydashboard::valueBox(
        nrow(sim_data$summary),
        "Replications (rows)", icon = icon("repeat"),
        color = "teal"
      )
    })
    output$box_ent <- shinydashboard::renderValueBox({
      shinydashboard::valueBox(
        nrow(sim_data$entities),
        "Entity rows", icon = icon("dot-circle"),
        color = "orange"
      )
    })
    output$box_profile <- shinydashboard::renderValueBox({
      shinydashboard::valueBox(
        sim_data$load_info$profile_type,
        "Profile type", icon = icon("microchip"),
        color = "purple"
      )
    })

    metric_distribution <- function(metric, label) {
      d <- sim_data$summary
      if (!metric %in% names(d) || !any(is.finite(d[[metric]])))
        return(plotly::plotly_empty() |>
          plotly::layout(annotations = list(list(
            text = paste(label, "is not available in the loaded summary."),
            showarrow = FALSE, x = 0.5, y = 0.5,
            xref = "paper", yref = "paper"))))
      d <- d[is.finite(d[[metric]]), , drop = FALSE]
      density <- all(table(d$scenario) >= 2L)
      p <- ggplot2::ggplot(d,
        ggplot2::aes(x = .data[[metric]], fill = .data$scenario)) +
        (if (density) ggplot2::geom_density(alpha = 0.4) else
          ggplot2::geom_histogram(bins = 20, position = "identity", alpha = 0.4)) +
        ggplot2::labs(x = label, y = if (density) "Density" else "Replications",
                      fill = NULL) + dynasimR::theme_dynasimR()
      plotly::ggplotly(p) |>
        plotly::layout(
          legend = list(orientation = "h", x = 0, y = 1.12,
                         xanchor = "left", yanchor = "bottom"),
          margin = list(t = 40, b = 55)
        )
    }

    output$event_dist <- plotly::renderPlotly({
      metric_distribution(if (profile_b) "progress_gain" else "event_rate",
        if (profile_b) "Progress gain (input units)" else "Event rate")
    })

    output$compliance_dist <- plotly::renderPlotly({
      metric_distribution(if (profile_b) "completion_rate" else "compliance_index",
        if (profile_b) "Completion rate (fraction)" else "Compliance Index")
    })

    output$summary_tbl <- DT::renderDT({
      metrics <- setdiff(names(sim_data$summary)[
        vapply(sim_data$summary, is.numeric, logical(1))], "replication")
      DT::datatable(
        sim_data$summary |>
          dplyr::group_by(.data$scenario) |>
          dplyr::summarise(
            n = dplyr::n(),
            dplyr::across(dplyr::all_of(metrics),
                          ~ round(stats::median(.x, na.rm = TRUE),
                                  3)),
            .groups = "drop"
          ),
        options = list(pageLength = 15, scrollX = TRUE)
      )
    })
  })
}
