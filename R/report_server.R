# report_server.R — Shiny server logic for AI report generation
#
# Connects to: report_ui.R (same namespace), viz_server.R (reactive inputs)
# Depends on:  utils_llm.R (stream_llm_response, check_llm_available)
#              utils_report.R (build_cpia_prompt, format_report_docx)


#' Report Module Server
#'
#' @title Report Server
#'
#' @description
#' Shiny server function for the AI-generated CPIA assessment module. Handles:
#' \itemize{
#'   \item Triggering LLM report generation when the "Generate Report" button
#'         is clicked.
#'   \item Streaming the LLM response token-by-token into the UI via
#'         `stream_llm_response()`.
#'   \item Managing button state (generating / ready) through reactive flags.
#'   \item Revealing the download button once generation is complete.
#'   \item Producing a Word document for download via `format_report_docx()`.
#'   \item Surfacing user-friendly error messages without crashing the session.
#' }
#'
#' This module is a **consumer** of the viz module's reactive state. It reads
#' `country`, `question`, `question_label`, and `plot_data` but does not own
#' or modify any of them.
#'
#' @param id Character. The Shiny module namespace ID. Must match `report_ui()`.
#' @param country Reactive expression returning the selected country name
#'   (character scalar, e.g. `reactive(input$country)`).
#' @param question Reactive expression returning the selected question code
#'   (character scalar, e.g. `reactive(input$question)`).
#' @param question_label Reactive expression returning the human-readable
#'   question label (character scalar).
#' @param plot_data Reactive expression returning the prepared plot data frame,
#'   as produced by `prepare_plot_data()`.
#'
#' @return Called for side effects only (standard Shiny module server pattern).
#'
#' @importFrom shiny moduleServer reactiveVal observeEvent renderUI req
#'   downloadButton downloadHandler tagList tags div
#'
#' @keywords internal
report_server <- function(id, country, question, question_label, plot_data) {
  shiny::moduleServer(id, function(input, output, session) {

    # ── State ──────────────────────────────────────────────────────────────────

    # Accumulated LLM output — updates on each token during streaming
    report_text  <- shiny::reactiveVal(NULL)

    # TRUE once streaming finishes — controls download button visibility
    report_ready <- shiny::reactiveVal(FALSE)

    # TRUE while the LLM call is in progress — drives spinner in output
    generating   <- shiny::reactiveVal(FALSE)

    # ── Generate report on button click ───────────────────────────────────────
    shiny::observeEvent(input$generate, {

      shiny::req(country(), question(), plot_data())

      if (nrow(plot_data()) == 0) {
        report_text(
          "No data available for the current selection. Please adjust your inputs."
        )
        return()
      }

      # Reset for new generation
      report_text(NULL)
      report_ready(FALSE)
      generating(TRUE)

      # Build prompt — wrapped in tryCatch so a bad input does not crash session
      prompt <- tryCatch(
        build_cpia_prompt(
          country        = country(),
          question       = question(),
          question_label = question_label(),
          plot_data      = plot_data()
        ),
        error = function(e) {
          report_text(sprintf("Could not build report prompt: %s", e$message))
          generating(FALSE)
          NULL
        }
      )

      if (is.null(prompt)) return()

      # Check endpoint before streaming to give a clear error if Ollama is off
      if (!check_llm_available()) {
        report_text(paste(
          "Could not connect to the AI model.",
          "Please ensure the service is running or contact your administrator.",
          sprintf(
            "(Endpoint: %s)",
            Sys.getenv("CPIA_LLM_BASE_URL", "http://localhost:11434/v1")
          )
        ))
        generating(FALSE)
        return()
      }

      # Stream response — updates report_text() on each token
      tryCatch(
        stream_llm_response(
          prompt       = prompt,
          reactive_val = report_text,
          on_complete  = function(text) {
            generating(FALSE)
            report_ready(TRUE)
          }
        ),
        error = function(e) {
          report_text(sprintf(
            "An error occurred during report generation: %s\n\nPlease try again.",
            e$message
          ))
          generating(FALSE)
        }
      )
    })

    # ── Report output ──────────────────────────────────────────────────────────
    output$report_output <- shiny::renderUI({

      # Spinner before first token arrives
      if (isTRUE(generating()) && is.null(report_text())) {
        return(shiny::div(
          class = "d-flex align-items-center gap-2 text-muted p-3",
          shiny::tags$span(
            class = "spinner-border spinner-border-sm",
            role  = "status"
          ),
          "Generating assessment\u2026"
        ))
      }

      # Render streamed / complete text as paragraphs
      if (!is.null(report_text())) {
        paragraphs <- strsplit(report_text(), "\n\n")[[1]]
        paragraphs <- paragraphs[nzchar(trimws(paragraphs))]

        shiny::tagList(
          lapply(paragraphs, function(p) shiny::tags$p(trimws(p), class = "mb-2")),
          # Inline spinner while still streaming
          if (isTRUE(generating())) {
            shiny::tags$span(
              class = "spinner-grow spinner-grow-sm text-muted ms-1",
              role  = "status"
            )
          }
        )
      }
    })

    # ── Download button (server-rendered — hidden until report is ready) ──────
    output$download_btn <- shiny::renderUI({
      if (!isTRUE(report_ready())) return(NULL)

      shiny::downloadButton(
        outputId = session$ns("download_docx"),
        label    = "Download (.docx)",
        icon     = shiny::icon("file-word"),
        class    = "btn btn-outline-secondary btn-sm"
      )
    })

    # ── Word document download handler ─────────────────────────────────────────
    output$download_docx <- shiny::downloadHandler(
      filename = function() {
        sprintf(
          "CPIA_%s_%s_%s.docx",
          gsub("[^A-Za-z0-9]", "_", country()),
          toupper(question()),
          format(Sys.Date(), "%Y%m%d")
        )
      },
      content = function(file) {
        shiny::req(report_text())

        doc <- format_report_docx(
          report_text    = report_text(),
          country        = country(),
          question_label = question_label(),
          question       = question()
        )

        print(doc, target = file)
      }
    )
  })
}
