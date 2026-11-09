#' Kaplan-Meier curves
#'
#' Plots a `dynasimR_km` object.
#'
#' @param km_result A `dynasimR_km` object.
#' @param show_ci Logical. Show CI ribbon. Default `TRUE`.
#' @param show_risktable Logical. Show numbers at risk immediately before
#'   each displayed time (requires patchwork).
#'   Default `FALSE`.
#' @param show_pval Logical. Annotate log-rank p-value. Default `TRUE`.
#' @param show_median Logical. Draw horizontal 50% reference line.
#'   Default `TRUE`.
#' @param color_by Character. Palette hint: `"policy"` uses policy colours
#'   for at most two strata; otherwise uses a discrete palette. Curves always
#'   retain the strata fitted by [km_estimate()]; this does not regroup them.
#' @param title,subtitle,xlab,ylab Character overrides.
#' @param xlim Numeric length-2. Restrict x range. Default `NULL`.
#' @param manuscript_width Numeric. Retained for compatibility; does not
#'   resize the plot. Set `width_mm` in [export_figure()] instead.
#' @param ... Unused.
#'
#' @return A ggplot2 object, or a patchwork composition when
#'   `show_risktable = TRUE`.
#' @examples
#' sim <- load_example_data()
#' km <- km_estimate(sim, endpoint = "stage2", stratify_by = "scenario")
#' plot_km(km)
#' @export
plot_km <- function(km_result,
                    show_ci          = TRUE,
                    show_risktable   = FALSE,
                    show_pval        = TRUE,
                    show_median      = TRUE,
                    color_by         = "scenario",
                    title            = NULL,
                    subtitle         = NULL,
                    xlab             = "Time",
                    ylab             = "Survival probability",
                    xlim             = NULL,
                    manuscript_width = 174,
                    ...) {

  if (!inherits(km_result, "dynasimR_km"))
    cli::cli_abort("{.arg km_result} must be a dynasimR_km object.")

  d <- km_result$tidy
  if (nrow(d) == 0) {
    return(ggplot2::ggplot() +
             ggplot2::annotate("text", x = 1, y = 1,
                               label = "No survival data") +
             theme_dynasimR())
  }

  # Include the initial survival probability before the first observation.
  d <- dplyr::bind_rows(lapply(split(d, d$strata), function(s) {
    s <- s[order(s$time), , drop = FALSE]
    if (min(s$time) > 0) {
      initial <- s[1, , drop = FALSE]
      initial$time <- 0
      initial$estimate <- 1
      for (nm in intersect(c("conf.low", "conf.high"), names(initial)))
        initial[[nm]] <- if (any(is.finite(s[[nm]]))) 1 else NA_real_
      s <- dplyr::bind_rows(initial, s)
    }
    s
  }))
  n_strata <- length(unique(d$strata))
  palette <- if (identical(color_by, "policy") && n_strata <= 2L)
    c(dynasimR_colors()$GROUP_A, dynasimR_colors()$GROUP_B)
  else
    .safe_viridis(max(1, n_strata))

  sizes <- table(d$strata)
  single <- d$strata %in% names(sizes)[sizes == 1L]

  p <- ggplot2::ggplot(
    d,
    ggplot2::aes(x = .data$time, y = .data$estimate,
                 color = .data$strata, fill = .data$strata)
  ) +
    ggplot2::geom_step(data = d[!single, , drop = FALSE], linewidth = 0.8)
  if (any(single))
    p <- p + ggplot2::geom_point(data = d[single, , drop = FALSE], size = 2)

  if (show_ci && all(c("conf.low", "conf.high") %in% names(d))) {
    # Expand intervals into steps; analytic limits can be undefined after
    # complete depletion. Omit those limits, retaining the survival curve.
    ribbon <- dplyr::bind_rows(lapply(split(d, d$strata), function(s) {
      if (nrow(s) > 1L) {
        before <- s[-nrow(s), , drop = FALSE]
        before$time <- s$time[-1L]
        s <- dplyr::bind_rows(s, before) |>
          dplyr::arrange(.data$time, dplyr::desc(.data$estimate))
      }
      s[is.finite(s$conf.low) & is.finite(s$conf.high), , drop = FALSE]
    }))
    p <- p +
      ggplot2::geom_ribbon(
        data = ribbon,
        ggplot2::aes(ymin = .data$conf.low,
                     ymax = .data$conf.high),
        alpha = 0.15, color = NA
      )
  }

  if (show_median)
    p <- p +
      ggplot2::geom_hline(yintercept = 0.5, linetype = "dashed",
                          color = "gray60", linewidth = 0.4)

  if (!is.null(xlim))
    p <- p + ggplot2::coord_cartesian(xlim = xlim)

  p <- p +
    ggplot2::scale_color_manual(values = palette) +
    ggplot2::scale_fill_manual(values  = palette) +
    ggplot2::scale_y_continuous(
      limits = c(0, 1),
      labels = function(x) paste0(round(x * 100), "%")
    ) +
    ggplot2::labs(
      title    = title,
      subtitle = subtitle,
      x        = xlab,
      y        = ylab,
      color    = NULL,
      fill     = NULL,
      caption  = .km_caption(km_result, show_pval)
    ) +
    theme_dynasimR()

  if (show_pval && !is.null(km_result$logrank) &&
      is.finite(km_result$logrank$p_value)) {
    pv  <- km_result$logrank$p_value
    pvt <- paste0("Log-rank p ", .format_p(pv))
    p <- p +
      ggplot2::annotate(
        "text",
        x = max(d$time, na.rm = TRUE) * 0.05,
        y = 0.08,
        label = pvt,
        hjust = 0, size = 3, color = "#444444"
      )
  }

  if (show_risktable) {
    if (!requireNamespace("patchwork", quietly = TRUE))
      cli::cli_abort("Install {.pkg patchwork} to display a risk table.")
    limits <- if (is.null(xlim)) range(d$time) else xlim
    times <- pretty(limits, n = 5)
    times <- times[times >= limits[1] & times <= limits[2]]
    if (!length(times)) times <- limits
    risks <- .km_risk_table(km_result, times)
    risk_plot <- ggplot2::ggplot(risks, ggplot2::aes(
      x = .data$time, y = .data$strata, label = .data$n.risk
    )) +
      ggplot2::geom_text(show.legend = FALSE, size = 3) +
      ggplot2::scale_x_continuous(breaks = times) +
      ggplot2::coord_cartesian(xlim = limits) +
      ggplot2::labs(x = xlab, y = NULL, title = "Number at risk") +
      theme_dynasimR()
    p <- p + ggplot2::scale_x_continuous(breaks = times)
    p <- patchwork::wrap_plots(p, risk_plot, ncol = 1,
                              heights = c(3, max(1, n_strata / 3)))
  }
  p
}

.km_risk_table <- function(km_result, times) {
  s <- summary(km_result$fit, times = times, extend = TRUE)
  strata <- if (is.null(s$strata))
    rep(as.character(km_result$tidy$strata[1]), length(s$time))
  else as.character(s$strata)
  tibble::tibble(time = s$time, strata = strata, n.risk = s$n.risk)
}

#' Forest plot of Cox hazard ratios
#'
#' @param cox_result A `dynasimR_cox` object.
#' @param reference_label Character. Label for HR = 1 reference line.
#'   Default `"No effect (HR = 1)"`.
#' @param ... Unused.
#' @return A ggplot2 object.
#' @examples
#' sim <- load_example_data()
#' cx <- cox_model(sim, endpoint = "stage2")
#' plot_forest(cx)
#' @export
plot_forest <- function(cox_result,
                        reference_label = "No effect (HR = 1)",
                        ...) {

  if (!inherits(cox_result, "dynasimR_cox"))
    cli::cli_abort(
      "{.arg cox_result} must be a dynasimR_cox object."
    )

  d <- cox_result$forest_data
  if (nrow(d) == 0)
    cli::cli_abort("No scenario terms in forest data.")

  ggplot2::ggplot(
    d,
    ggplot2::aes(x = .data$HR,
                 y = stats::reorder(.data$term, .data$HR),
                 xmin = .data$CI_low, xmax = .data$CI_high)
  ) +
    ggplot2::geom_vline(xintercept = 1, linetype = "dashed",
                        color = "gray60", linewidth = 0.5) +
    ggplot2::geom_errorbar(orientation = "y", width = 0.2, linewidth = 0.6,
                            color = dynasimR_colors()$NEUTRAL) +
    ggplot2::geom_point(
      ggplot2::aes(color = .data$p.value < 0.05),
      size = 3
    ) +
    ggplot2::scale_color_manual(
      values = c("TRUE"  = dynasimR_colors()$GROUP_A,
                 "FALSE" = dynasimR_colors()$NEUTRAL),
      labels = c("TRUE" = "p < 0.05", "FALSE" = "n.s."),
      name   = NULL
    ) +
    ggplot2::scale_x_log10() +
    ggplot2::labs(
      x = "Hazard ratio (log scale)",
      y = NULL,
      caption = glue::glue(
        "Reference: {cox_result$params$reference_scenario}"
      )
    ) +
    theme_dynasimR()
}
