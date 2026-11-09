#' Launch the dynasimR Shiny dashboard
#'
#' Starts the interactive analysis app bundled with dynasimR. The app
#' requires simulation data; either supply a directory via `data_dir`
#' or leave it `NULL` to use the bundled example data.
#' Profile B supports progress/completion overview, comparison and summary
#' table export. Other dashboard analyses require Profile A. Mixed-profile
#' directories must be separated for dashboard use; the R loading API can
#' still read them together.
#'
#' @param data_dir Character. Path to a directory of simulation
#'   outputs. Default `NULL` = use bundled example data.
#' @param port Integer. Port for the local server. Default `3838`.
#' @param launch.browser Logical. Open in browser. Default `TRUE`.
#' @param ... Additional arguments forwarded to [shiny::runApp()].
#' @return Does not return (blocks until the app is closed).
#' @export
#' @examples
#' # Starts an interactive Shiny session; run it from an interactive R
#' # session.
#' if (interactive() && all(check_app_dependencies()$installed)) {
#'   launch_app()
#' }
launch_app <- function(data_dir       = NULL,
                       port           = 3838,
                       launch.browser = TRUE,
                       ...) {

  missing <- .app_dependencies()[!vapply(.app_dependencies(),
    requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing))
    cli::cli_abort(
      c("Dashboard packages required: {.pkg {missing}}.",
        "i" = "Run {.code check_app_dependencies()} for installation instructions.")
    )

  app_dir <- system.file("app", package = "dynasimR")
  if (!nzchar(app_dir) || !dir.exists(app_dir))
    cli::cli_abort(
      "App directory not found. Is dynasimR installed correctly?"
    )

  previous_options <- options("dynasimR.data_dir")
  on.exit(options(previous_options), add = TRUE)
  if (!is.null(data_dir)) {
    if (!is.character(data_dir) || length(data_dir) != 1L || is.na(data_dir))
      cli::cli_abort("{.arg data_dir} must name one directory.")
    if (!dir.exists(data_dir))
      cli::cli_abort("data_dir not found: {.path {data_dir}}")
    data_dir <- normalizePath(data_dir, mustWork = TRUE)
    options(dynasimR.data_dir = data_dir)
    cli::cli_alert_info("Loading data from {.path {data_dir}}")
  } else {
    options(dynasimR.data_dir = NULL)
    cli::cli_alert_info("Using bundled example data")
  }

  cli::cli_alert_success(
    "Starting dynasimR dashboard on port {port} ..."
  )
  shiny::runApp(
    appDir         = app_dir,
    port           = port,
    launch.browser = launch.browser,
    ...
  )
}

#' Check availability of Shiny-app dependencies
#'
#' Inspects the `Suggests:` packages required by the embedded Shiny
#' dashboard, including table export, and prints which ones are installed.
#' This function reports an installation command; it does not install packages.
#'
#' @return A tibble with columns `package`, `installed`, `version`,
#'   invisibly.
#' @examples
#' check_app_dependencies()
#' @export
check_app_dependencies <- function() {
  pkgs <- .app_dependencies()

  status <- purrr::map_dfr(pkgs, function(p) {
    ok <- requireNamespace(p, quietly = TRUE)
    tibble::tibble(
      package   = p,
      installed = ok,
      version   = if (ok)
        as.character(utils::packageVersion(p)) else NA_character_
    )
  })

  missing <- dplyr::filter(status, !.data$installed)
  if (nrow(missing) > 0) {
    cli::cli_alert_warning(
      "Missing packages: {.pkg {missing$package}}"
    )
    cli::cli_code(
      paste0('install.packages(c("',
             paste(missing$package, collapse = '","'),
             '"))')
    )
  } else {
    cli::cli_alert_success("All Shiny-app dependencies available.")
  }
  invisible(status)
}

.app_dependencies <- function() {
  c("shiny", "shinydashboard", "shinyWidgets", "plotly", "DT", "xtable")
}

.dashboard_profile <- function(data) {
  profile <- data$load_info$profile_type
  if (identical(profile, "mixed"))
    cli::cli_abort("The dashboard cannot combine Profile A and Profile B. Use separate data directories for each profile; read_simulation() can still load mixed data for analysis in R.")
  if (length(profile) != 1L || is.na(profile) ||
      !profile %in% c("Profile_A", "Profile_B"))
    cli::cli_abort("The dashboard requires an identified Profile A or Profile B dataset.")
  profile
}
