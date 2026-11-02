#' Load simulation outputs into the dynasimR standard format
#'
#' Reads CSV outputs from any discrete-event or agent-based
#' simulation framework that follows the dynasimR file-naming
#' convention and validates them against the dynasimR data schema.
#' Returns a structured S3 object of class `dynasimR_data`.
#'
#' @param data_dir Character. Path to the directory containing
#'   simulation outputs. Files are expected to follow the pattern
#'   `{scenario_id}_summary.csv`, `{scenario_id}_entities.csv` and
#'   (optionally) `{scenario_id}_timeseries.csv`.
#' @param scenarios Character vector. Scenario IDs to load. Default
#'   `NULL` loads every scenario found in `data_dir`.
#' @param validate Logical. Run [validate_dynasimR_data()] on the
#'   loaded tables. Default `TRUE`. Requires nonempty summary and entity
#'   files, matching scenario IDs and valid schemas. `FALSE` bypasses
#'   those checks for inspection of incomplete output.
#' @param verbose Logical. Print progress messages. Default `TRUE`.
#'
#' @details An optional `scenario_metadata.csv` uses one unique `id` per
#'   scenario. Its columns are joined without suffixes; conflicts with
#'   nonmissing table values are errors when `validate = TRUE`. With
#'   validation disabled, existing table values take precedence. The bundled
#'   scenario settings are used only for the package example directory,
#'   with local metadata taking precedence over bundled descriptions.
#'   External files never inherit example settings merely by sharing an ID.
#'   Each row retains its scenario's `profile_type`; `load_info$profile_type`
#'   is `"mixed"` when the loaded scenarios use different profiles.
#' @return An S3 object of class `dynasimR_data` (a list) with slots
#'   `summary`, `entities`, `timeseries`, `metadata` and `load_info`.
#' @export
#' @examples
#' \dontrun{
#' sim <- read_simulation("data/raw/")
#' sim <- read_simulation("data/raw/",
#'                        scenarios = c("A-S00", "A-S07", "A-S08"))
#' sim <- read_simulation(system.file("extdata", package = "dynasimR"))
#' }
read_simulation <- function(data_dir,
                            scenarios = NULL,
                            validate  = TRUE,
                            verbose   = TRUE) {

  if (!is.character(data_dir) || length(data_dir) != 1L ||
      is.na(data_dir) || !dir.exists(data_dir))
    cli::cli_abort("{.arg data_dir} must name an existing directory.")
  for (nm in c("validate", "verbose")) {
    value <- get(nm)
    if (!is.logical(value) || length(value) != 1L || is.na(value))
      cli::cli_abort("{nm} must be TRUE or FALSE.")
  }
  if (!is.null(scenarios) &&
      (!is.character(scenarios) || anyNA(scenarios) ||
       any(!nzchar(trimws(scenarios)))))
    cli::cli_abort("{.arg scenarios} must contain nonmissing scenario IDs.")

  summary_files <- list.files(data_dir, pattern = "_summary\\.csv$")
  available <- sub("_summary\\.csv$", "", summary_files)
  if (length(available) == 0)
    cli::cli_abort(c("No simulation outputs found in {.path {data_dir}}.",
                    "i" = "Each scenario needs a _summary.csv file."))
  if (!is.null(scenarios)) {
    missing_sc <- setdiff(scenarios, available)
    if (length(missing_sc) > 0)
      cli::cli_warn("Scenarios not found: {.val {missing_sc}}")
    scenarios <- intersect(scenarios, available)
    if (length(scenarios) == 0)
      cli::cli_abort("No matching scenarios in {.path {data_dir}}.")
  } else {
    scenarios <- available
  }

  read_csv <- function(path) {
    tbl <- readr::read_csv(path, show_col_types = FALSE, progress = FALSE,
                          name_repair = "minimal")
    if (validate && (anyDuplicated(names(tbl)) || any(!nzchar(names(tbl)))))
      cli::cli_abort("CSV {.path {path}} has empty or duplicate column names.")
    if (validate && nrow(readr::problems(tbl)) > 0)
      cli::cli_abort("CSV {.path {path}} has parsing problems.")
    tbl
  }
  load_table <- function(sc, suffix) {
    path <- file.path(data_dir, paste0(sc, "_", suffix, ".csv"))
    if (!file.exists(path)) {
      if (validate && suffix != "timeseries")
        cli::cli_abort("Required simulation file {.path {path}} is missing.")
      return(tibble::tibble())
    }
    tbl <- read_csv(path)
    if (validate && suffix != "timeseries" && nrow(tbl) == 0)
      cli::cli_abort("Required simulation file {.path {path}} has no rows.")
    if (!"scenario" %in% names(tbl)) {
      tbl$scenario <- rep(sc, nrow(tbl))
    } else if (validate &&
               (anyNA(tbl$scenario) || any(tbl$scenario != sc))) {
      cli::cli_abort("Scenario IDs in {.path {path}} must all equal {.val {sc}}.")
    }
    tbl
  }
  detect_profile <- function(tbl) {
    has_progress <- "progress_gain" %in% names(tbl)
    has_event <- "event_rate" %in% names(tbl)
    if (has_progress && has_event) "mixed"
    else if (has_progress) "Profile_B"
    else if (has_event) "Profile_A"
    else "unknown"
  }
  if (verbose) cli::cli_alert_info(
    "Loading {length(scenarios)} scenario{?s} from {.path {data_dir}}"
  )
  tables <- lapply(scenarios, function(sc) {
    summary <- load_table(sc, "summary")
    profile <- detect_profile(summary)
    result <- list(summary = summary,
                   entities = load_table(sc, "entities"),
                   timeseries = load_table(sc, "timeseries"))
    for (nm in names(result)) {
      tbl <- result[[nm]]
      if (validate && "profile_type" %in% names(tbl) &&
          profile %in% c("Profile_A", "Profile_B") &&
          any(!is.na(tbl$profile_type) & tbl$profile_type != profile))
        cli::cli_abort("Conflicting profile_type in {.val {sc}} {nm} table.")
      if (!"profile_type" %in% names(tbl))
        tbl$profile_type <- rep(profile, nrow(tbl))
      else tbl$profile_type[is.na(tbl$profile_type)] <- profile
      result[[nm]] <- tbl
    }
    if (validate) result <- validate_dynasimR_data(result, strict = TRUE)
    result
  })
  names(tables) <- scenarios
  result <- lapply(c("summary", "entities", "timeseries"), function(nm)
    dplyr::bind_rows(lapply(tables, `[[`, nm)))
  names(result) <- c("summary", "entities", "timeseries")

  meta_path <- file.path(data_dir, "scenario_metadata.csv")
  meta <- if (file.exists(meta_path)) read_csv(meta_path)
          else tibble::tibble(id = scenarios)
  .require_cols(meta, "id", where = "scenario_metadata.csv")
  if (anyNA(meta$id) || any(!nzchar(trimws(as.character(meta$id)))) ||
      anyDuplicated(meta$id))
    cli::cli_abort("scenario_metadata.csv needs unique, nonmissing IDs.")
  meta$id <- as.character(meta$id)
  meta <- dplyr::left_join(tibble::tibble(id = scenarios), meta, by = "id")
  example_dir <- system.file("extdata", package = "dynasimR")
  is_example <- nzchar(example_dir) &&
    identical(normalizePath(data_dir), normalizePath(example_dir))
  if (is_example) {
    bundled <- getExportedValue("dynasimR", "scenario_meta")
    absent <- setdiff(names(bundled), names(meta))
    meta <- dplyr::left_join(meta, bundled[c("id", absent)], by = "id")
  }
  join_meta <- function(tbl) {
    if (nrow(tbl) == 0) return(tbl)
    matched <- meta[match(tbl$scenario, meta$id), , drop = FALSE]
    for (nm in setdiff(names(meta), "id")) {
      incoming <- matched[[nm]]
      if (!nm %in% names(tbl)) {
        tbl[[nm]] <- incoming
      } else {
        current <- tbl[[nm]]
        conflict <- !is.na(current) & !is.na(incoming) &
          as.character(current) != as.character(incoming)
        if (validate && any(conflict))
          cli::cli_abort("Metadata conflicts with table column {.val {nm}}.")
        tbl[[nm]] <- dplyr::coalesce(current, incoming)
      }
    }
    tbl
  }
  result$summary <- join_meta(result$summary)
  result$entities <- join_meta(result$entities)
  result$timeseries <- join_meta(result$timeseries)
  result$metadata <- meta
  profiles <- unique(result$summary$profile_type)
  profile_type <- if (length(profiles) == 1L) profiles else "mixed"

  missing_prefix <- scenarios[!grepl("^[AB]-", scenarios)]
  if (length(missing_prefix) > 0)
    cli::cli_warn(c(
      "Scenario IDs without prefix: {.val {missing_prefix}}",
      "i" = "Recommended prefixes are 'A-' (Profile A) and 'B-' (Profile B)."
    ))
  result$load_info <- list(
    timestamp = Sys.time(), data_dir = normalizePath(data_dir),
    scenarios = scenarios, profile_type = profile_type,
    n_summary = nrow(result$summary), n_entities = nrow(result$entities)
  )
  if (validate) result <- validate_dynasimR_data(result, strict = TRUE)
  if (verbose) cli::cli_alert_success(
    "Loaded {nrow(result$summary)} summary row{?s}, ",
    "{nrow(result$entities)} entit{?y/ies} [{profile_type}]"
  )
  structure(result, class = c("dynasimR_data", "list"))
}

#' @export
print.dynasimR_data <- function(x, ...) {
  cli::cli_h1("dynasimR_data")
  cli::cli_bullets(c(
    "*" = "Scenarios: {.val {length(x$load_info$scenarios)}}",
    "*" = "Profile: {.val {x$load_info$profile_type}}",
    "*" = "Summary rows: {.val {nrow(x$summary)}}",
    "*" = "Entity events: {.val {nrow(x$entities)}}",
    "*" = "Loaded: {.val {format(x$load_info$timestamp, '%Y-%m-%d %H:%M')}}",
    "*" = "Path: {.path {x$load_info$data_dir}}"
  ))
  invisible(x)
}

#' Load the package-bundled example dataset
#'
#' Convenience wrapper around [read_simulation()] pointing at the
#' CSVs shipped in `inst/extdata/`.
#'
#' @return A `dynasimR_data` object.
#' @export
#' @examples
#' sim <- load_example_data()
#' print(sim)
load_example_data <- function() {
  ext <- system.file("extdata", package = "dynasimR")
  if (!nzchar(ext) || !dir.exists(ext))
    cli::cli_abort("Example data directory not found.")
  read_simulation(
    data_dir = ext,
    validate = TRUE,
    verbose  = FALSE
  )
}
