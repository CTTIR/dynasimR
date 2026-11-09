#' Colour palette for dynasimR plots
#'
#' Returns a named list of hex colours used by all `plot_*` functions.
#'
#' @return A named list with entries `GROUP_A`, `GROUP_B`, `GROUP_C`,
#'   `POSITIVE`, `NEGATIVE`, `NEUTRAL`, `ACCENT`, `BG`.
#' @export
#' @examples
#' pal <- dynasimR_colors()
#' pal$GROUP_A
dynasimR_colors <- function() {
  list(
    GROUP_A  = "#1B3A6B",
    GROUP_B  = "#A61C24",
    GROUP_C  = "#C99A2E",
    POSITIVE = "#2E7D32",
    NEGATIVE = "#212121",
    NEUTRAL  = "#607D8B",
    ACCENT   = "#2E75B6",
    BG       = "#F5F7FA"
  )
}

#' ggplot2 theme for dynasimR figures
#'
#' A minimalist ggplot2 theme tuned for publication-quality single
#' and double-column output at 11 pt base size.
#'
#' @param base_size Numeric. Base font size. Default `11`.
#' @param legend_pos Character. Legend position. Default `"bottom"`.
#' @return A ggplot2 theme object.
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point() +
#'   theme_dynasimR()
#' @export
theme_dynasimR <- function(base_size = 11, legend_pos = "bottom") {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.title       = ggplot2::element_text(
        face = "bold", color = "#1B3A6B", size = base_size + 1),
      plot.subtitle    = ggplot2::element_text(
        color = "#666666", size = base_size - 1),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(
        color = "#E8E8E8", linewidth = 0.3),
      legend.position  = legend_pos,
      legend.title     = ggplot2::element_text(face = "bold"),
      strip.text       = ggplot2::element_text(face = "bold"),
      plot.caption     = ggplot2::element_text(
        color = "#888888", size = base_size - 2, hjust = 0)
    )
}

#' Colour scale for entity group
#'
#' Applies dynasimR group colours (`A`/`B`/`C`) to a ggplot2
#' `color` aesthetic.
#'
#' @param ... Arguments passed to [ggplot2::scale_color_manual()].
#' @return A ggplot2 scale object.
#' @examples
#' library(ggplot2)
#' d <- data.frame(x = 1:3, y = 3:1, group = c("A", "B", "C"))
#' ggplot(d, aes(x, y, color = group)) +
#'   geom_point(size = 3) +
#'   scale_color_group_dynasimR()
#' @export
scale_color_group_dynasimR <- function(...) {
  ggplot2::scale_color_manual(
    values = c(
      A = dynasimR_colors()$GROUP_A,
      B = dynasimR_colors()$GROUP_B,
      C = dynasimR_colors()$GROUP_C
    ), ...
  )
}

#' Fill scale for entity group
#'
#' As [scale_color_group_dynasimR()] but for the `fill` aesthetic.
#'
#' @param ... Arguments passed to [ggplot2::scale_fill_manual()].
#' @return A ggplot2 scale object.
#' @examples
#' library(ggplot2)
#' d <- data.frame(group = c("A", "B", "C"), n = c(4, 6, 2))
#' ggplot(d, aes(group, n, fill = group)) +
#'   geom_col() +
#'   scale_fill_group_dynasimR()
#' @export
scale_fill_group_dynasimR <- function(...) {
  ggplot2::scale_fill_manual(
    values = c(
      A = dynasimR_colors()$GROUP_A,
      B = dynasimR_colors()$GROUP_B,
      C = dynasimR_colors()$GROUP_C
    ), ...
  )
}

#' Colour scale for policy
#'
#' @param ... Arguments passed to [ggplot2::scale_color_manual()].
#' @return A ggplot2 scale object.
#' @examples
#' library(ggplot2)
#' d <- data.frame(x = 1:4, y = c(1, 2, 2, 3),
#'                 policy = rep(c("policy_a", "policy_b"), 2))
#' ggplot(d, aes(x, y, color = policy)) +
#'   geom_point(size = 3) +
#'   scale_color_policy_dynasimR()
#' @export
scale_color_policy_dynasimR <- function(...) {
  ggplot2::scale_color_manual(
    values = c(
      policy_a = dynasimR_colors()$GROUP_A,
      policy_b = dynasimR_colors()$GROUP_B
    ),
    labels = c(
      policy_a = "Policy A",
      policy_b = "Policy B"
    ),
    ...
  )
}
