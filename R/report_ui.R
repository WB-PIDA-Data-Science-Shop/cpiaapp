# report_ui.R — Shiny UI for the AI report panel
#
# Connects to: report_server.R (via report_module.R)
# Placed in:   viz_ui.R as an additional card below the data table


#' Report Module UI
#'
#' @title Report UI
#'
#' @description
#' Shiny UI function for the AI-generated CPIA assessment panel. Renders:
#' \itemize{
#'   \item A card header with the panel title, "Generate Report" button
#'         (right-aligned), and a download button that appears only once a
#'         report has been generated.
#'   \item A card body with a streaming text output area and a permanent
#'         AI disclaimer notice.
#' }
#'
#' The panel is designed to sit below the existing plot and data table cards
#' in the cpiaapp dashboard. It does not contain any data selectors — those
#' are owned by the viz module.
#'
#' @param id Character. The Shiny module namespace ID. Must match the `id`
#'   passed to `report_server()`.
#'
#' @return A `bslib::card()` UI element.
#'
#' @importFrom shiny NS uiOutput actionButton icon tags div
#' @importFrom bslib card card_header card_body layout_columns
#'
#' @keywords internal
report_ui <- function(id) {
  ns <- shiny::NS(id)

  bslib::card(
    bslib::card_header(
      bslib::layout_columns(
        col_widths = c(6, 6),

        # Left: panel title
        shiny::tags$span(
          shiny::tags$i(class = "bi bi-robot me-2"),
          "AI-Generated Assessment"
        ),

        # Right: action buttons
        shiny::div(
          class = "d-flex justify-content-end align-items-center gap-2",
          shiny::actionButton(
            inputId = ns("generate"),
            label   = "Generate Report",
            icon    = shiny::icon("wand-magic-sparkles"),
            class   = "btn btn-primary btn-sm"
          ),
          # Download button rendered server-side — hidden until report is ready
          shiny::uiOutput(ns("download_btn"))
        )
      )
    ),

    bslib::card_body(
      # Report text output — updated token-by-token during streaming
      shiny::uiOutput(ns("report_output")),

      # Permanent disclaimer
      shiny::tags$div(
        class = "alert alert-warning mt-3 mb-0 small",
        shiny::tags$i(class = "bi bi-exclamation-triangle-fill me-1"),
        paste(
          "AI-generated content. This assessment was produced by a language",
          "model using CPIA score data as the sole input. It has not been",
          "reviewed by World Bank staff and should not be cited or distributed",
          "without human review."
        )
      )
    )
  )
}
