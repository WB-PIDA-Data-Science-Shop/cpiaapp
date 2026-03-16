# utils_report.R — Prompt construction and Word document export
#
# Functions:
#   load_prompt_file()    — load a markdown file from inst/prompts/
#   build_cpia_prompt()   — assemble system + user prompt from reactive data
#   format_report_docx()  — package report text as a Word document


# ── Prompt loading ─────────────────────────────────────────────────────────────

#' Load a prompt file from inst/prompts/
#'
#' @title Load Prompt File
#'
#' @description
#' Reads a markdown prompt file from the package's `inst/prompts/` directory
#' and returns its content as a single character string. Used by
#' `build_cpia_prompt()` to load the system prompt and style examples at
#' runtime, keeping long prompt text out of R source files.
#'
#' @param filename Character. The filename (with extension) of the prompt file
#'   inside `inst/prompts/`, e.g. `"cpia_report_prompt.md"`.
#'
#' @return A single character string containing the full file content, with
#'   lines joined by `"\n"`.
#'
#' @examples
#' \dontrun{
#' system_text <- load_prompt_file("cpia_report_prompt.md")
#' examples    <- load_prompt_file("cpia_style_examples.md")
#' }
#'
#' @keywords internal
load_prompt_file <- function(filename) {
  path <- system.file("prompts", filename, package = "cpiaapp")

  if (!nzchar(path)) {
    stop(
      sprintf(
        "Prompt file '%s' not found in inst/prompts/. ",
        filename
      ),
      "Reinstall the cpiaapp package to restore bundled prompt files.",
      call. = FALSE
    )
  }

  paste(readLines(path, warn = FALSE), collapse = "\n")
}


# ── Prompt construction ────────────────────────────────────────────────────────

#' Build a CPIA LLM prompt from reactive plot data
#'
#' @title Build CPIA Report Prompt
#'
#' @description
#' Constructs a fully populated LLM prompt for generating a CPIA country-level
#' criterion assessment. Loads the system prompt and style examples from
#' `inst/prompts/`, then injects the current data context — country, question,
#' score history, and comparator summary — into the user message.
#'
#' The function reads directly from the `plot_data` tibble already computed by
#' `prepare_plot_data()`, so no additional data wrangling is needed in the
#' server.
#'
#' @param country Character. The selected country name (e.g., `"Kenya"`).
#' @param question Character. The selected question code (e.g., `"q12a"`).
#' @param question_label Character. The human-readable question label
#'   (e.g., `"Property Rights and Rule-based Governance"`).
#' @param plot_data A data frame with columns `economy`, `year`, `score`,
#'   `display_name`, `group_type`, as returned by `prepare_plot_data()`.
#'
#' @return A named list with two character elements:
#'   \describe{
#'     \item{`system`}{The system prompt defining role, methodology, and style.}
#'     \item{`user`}{The user message containing all data for this report.}
#'   }
#'
#' @examples
#' \dontrun{
#' mock_data <- tibble::tibble(
#'   economy      = c("Kenya", "Kenya", "Africa"),
#'   year         = c(2022L, 2023L, 2023L),
#'   score        = c(3.0, 3.5, 3.1),
#'   display_name = c("Kenya", "Kenya", "Africa (AFR)"),
#'   group_type   = c("Selected Country", "Selected Country", "Comparator")
#' )
#' prompt <- build_cpia_prompt("Kenya", "q12a",
#'                             "Property Rights and Rule-based Governance",
#'                             mock_data)
#' names(prompt)  # "system" "user"
#' }
#'
#' @importFrom dplyr filter arrange select
#'
#' @keywords internal
build_cpia_prompt <- function(country, question, question_label, plot_data) {

  # ── Load prompt text from inst/prompts/ ────────────────────────────────────
  system_text    <- load_prompt_file("cpia_report_prompt.md")
  style_examples <- load_prompt_file("cpia_style_examples.md")

  # Append style examples to system prompt so they are always in context
  system_combined <- paste(system_text, "\n\n---\n\n## Writing Style Examples\n\n",
                           style_examples, sep = "")

  # ── Extract focal country score series ────────────────────────────────────
  country_scores <- plot_data |>
    dplyr::filter(economy == country, group_type == "Selected Country") |>
    dplyr::arrange(year) |>
    dplyr::select(year, score)

  score_series <- if (nrow(country_scores) == 0) {
    "No data available."
  } else {
    paste(
      apply(country_scores, 1, function(r) {
        sprintf("%s: %.1f", r[["year"]], as.numeric(r[["score"]]))
      }),
      collapse = ", "
    )
  }

  # ── Compute plain-language trend summary ──────────────────────────────────
  trend_text <- build_trend_text(country_scores, country)

  # ── Most recent year ────────────────────────────────────────────────
  all_years <- c(country_scores$year, plot_data$year)
  all_years <- all_years[!is.na(all_years)]
  latest_year <- if (length(all_years) > 0L) max(all_years) else NA_integer_

  # ── Comparator summary for most recent year ───────────────────────────────
  comparator_lines <- plot_data |>
    dplyr::filter(
      economy     != country,
      group_type  == "Comparator",
      year        == latest_year,
      !is.na(score)
    ) |>
    dplyr::arrange(display_name) |>
    dplyr::select(display_name, score)

  comparator_text <- if (nrow(comparator_lines) == 0) {
    "No comparators selected."
  } else {
    paste(
      apply(comparator_lines, 1, function(r) {
        sprintf("  %s: %.1f", r[["display_name"]], as.numeric(r[["score"]]))
      }),
      collapse = "\n"
    )
  }

  # ── Assemble user message ─────────────────────────────────────────────────
  user_text <- sprintf(
    paste(
      "Write a five-section CPIA assessment using ONLY the data below.",
      "Do not invent, infer, or add any data not explicitly provided.",
      "",
      "Country: %s",
      "Criterion: %s (%s)",
      "Most recent year: %s",
      "",
      "Score history (chronological):",
      "%s",
      "",
      "Trend summary:",
      "%s",
      "",
      "Comparators (%s, most recent year):",
      "%s",
      sep = "\n"
    ),
    country,
    question_label,
    question,
    latest_year,
    score_series,
    trend_text,
    latest_year,
    comparator_text
  )

  list(system = system_combined, user = user_text)
}


#' Build a plain-language trend description from a score series
#'
#' @title Build Trend Text
#'
#' @description
#' Internal helper that converts a two-column data frame of `year` and `score`
#' into a single sentence describing the overall trend. Used by
#' `build_cpia_prompt()` to populate the trend summary section of the user
#' message.
#'
#' @param scores_df A data frame with columns `year` (numeric/integer) and
#'   `score` (numeric), arranged chronologically. May have 0 rows.
#' @param country Character. Country name, used in the returned sentence.
#'
#' @return A single character string describing the trend (one sentence).
#'
#' @keywords internal
build_trend_text <- function(scores_df, country) {
  n <- nrow(scores_df)

  if (n == 0) {
    return(sprintf("No historical score data is available for %s.", country))
  }

  if (n == 1) {
    return(sprintf(
      "Only one data point is available: %.1f in %s.",
      scores_df$score[1], scores_df$year[1]
    ))
  }

  first_year  <- scores_df$year[1]
  last_year   <- scores_df$year[n]
  first_score <- scores_df$score[1]
  last_score  <- scores_df$score[n]
  change      <- last_score - first_score

  direction <- if (abs(change) < 0.01) {
    sprintf(
      "The score was unchanged at %.1f between %s and %s.",
      last_score, first_year, last_year
    )
  } else if (change > 0) {
    sprintf(
      "The score increased from %.1f in %s to %.1f in %s (net change: +%.1f).",
      first_score, first_year, last_score, last_year, change
    )
  } else {
    sprintf(
      "The score decreased from %.1f in %s to %.1f in %s (net change: %.1f).",
      first_score, first_year, last_score, last_year, change
    )
  }

  direction
}


# ── Word document export ───────────────────────────────────────────────────────

#' Format a CPIA AI report as a Word document
#'
#' @title Format Report as Word Document
#'
#' @description
#' Packages a generated AI report as a Word (.docx) document using the
#' `officer` package. The document includes a title heading, metadata lines
#' (country, criterion, generation date), the report body as styled paragraphs,
#' and a standard AI disclaimer.
#'
#' Double newlines in `report_text` are treated as paragraph breaks. The
#' disclaimer is appended after the body text.
#'
#' @param report_text Character. The generated report text from the LLM.
#'   Double newlines (`"\n\n"`) are used as paragraph separators.
#' @param country Character. The selected country name.
#' @param question_label Character. The human-readable question label.
#' @param question Character. The question code (e.g., `"q12a"`).
#'
#' @return An `officer` `rdocx` object. Write to file with
#'   `print(doc, target = "path/to/file.docx")`.
#'
#' @examples
#' \dontrun{
#' doc <- format_report_docx(
#'   report_text    = "Score Interpretation\n\nKenya's score...",
#'   country        = "Kenya",
#'   question_label = "Property Rights and Rule-based Governance",
#'   question       = "q12a"
#' )
#' print(doc, target = tempfile(fileext = ".docx"))
#' }
#'
#' @importFrom officer read_docx body_add_par
#'
#' @keywords internal
format_report_docx <- function(report_text, country, question_label, question) {

  doc <- officer::read_docx()

  # ── Title ──────────────────────────────────────────────────────────────────
  doc <- officer::body_add_par(
    doc,
    value = sprintf("CPIA Assessment: %s", country),
    style = "heading 1"
  )

  # ── Metadata ───────────────────────────────────────────────────────────────
  doc <- officer::body_add_par(
    doc,
    value = sprintf("Criterion: %s (%s)", question_label, toupper(question)),
    style = "Normal"
  )
  doc <- officer::body_add_par(
    doc,
    value = sprintf("Generated: %s", format(Sys.Date(), "%B %d, %Y")),
    style = "Normal"
  )

  # Spacer
  doc <- officer::body_add_par(doc, value = "", style = "Normal")

  # ── Report body ────────────────────────────────────────────────────────────
  paragraphs <- strsplit(report_text, "\n\n")[[1]]
  paragraphs <- paragraphs[nzchar(trimws(paragraphs))]

  for (para in paragraphs) {
    doc <- officer::body_add_par(doc, value = trimws(para), style = "Normal")
  }

  # Spacer
  doc <- officer::body_add_par(doc, value = "", style = "Normal")

  # ── Disclaimer ─────────────────────────────────────────────────────────────
  doc <- officer::body_add_par(
    doc,
    value = paste(
      "DISCLAIMER: This report was generated by an AI large language model using",
      "CPIA score data as the sole input. It has not been reviewed or validated",
      "by World Bank staff. It does not represent an official World Bank",
      "assessment and should not be cited or distributed without human review."
    ),
    style = "Normal"
  )

  doc
}
