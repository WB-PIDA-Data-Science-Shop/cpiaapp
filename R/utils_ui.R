#' Create Empty Plot Message
#'
#' Creates a plotly plot object displaying a "No Data Available" message. This provides
#' graceful empty state handling when user selections result in no data (e.g., country
#' has no data for selected question, or all comparators have missing values). The
#' function generates a blank plot with centered text annotations instead of showing
#' an error or empty axes.
#'
#' @param title Title text displayed at top of empty plot. Default: "No Data Available"
#' @param message Explanatory message text displayed in center of plot. Default provides
#'   guidance to try different selections. Supports multi-line text with \\n.
#' @param title_size Font size for title in pixels. Default: 16
#' @param message_size Font size for message text in pixels. Default: 14
#'
#' @return A plotly htmlwidget object with:
#'   - No visible axes or grid lines
#'   - Title text at top
#'   - Centered message annotation
#'   - Clean appearance suitable for user-facing empty states
#'   
#' @examples
#' \dontrun{
#' # Default message
#' empty_plot <- create_empty_plot_message()
#' 
#' # Custom message
#' custom_plot <- create_empty_plot_message(
#'   title = "No Data Found",
#'   message = "Please select a different country or time period."
#' )
#' }
#'
#' @importFrom plotly plot_ly layout
#'
#' @keywords internal
create_empty_plot_message <- function(
    title = "No Data Available",
    message = paste(
      "The selected country/comparators have no data for this criterion.",
      "Please try a different selection or dataset.",
      sep = "\n"
    ),
    title_size = 16,
    message_size = 14) {
  
  # Create blank plotly canvas
  plotly::plot_ly() |>
    plotly::layout(
      # Set title with custom size
      title = list(text = title, font = list(size = title_size)),
      # Hide x and y axes completely for clean empty state
      xaxis = list(visible = FALSE),
      yaxis = list(visible = FALSE),
      # Add centered text annotation with message
      annotations = list(
        list(
          text = message,
          xref = "paper",   # Relative positioning (0-1 scale)
          yref = "paper",
          x = 0.5,          # Centered horizontally
          y = 0.5,          # Centered vertically
          showarrow = FALSE, # No arrow pointer
          font = list(size = message_size)
        )
      )
    )
}

#' Create Empty Table Message
#'
#' Creates a DT datatable displaying a "No data available" message. This provides
#' graceful empty state handling for table outputs when user selections result in
#' no data. Instead of showing an empty table structure or error, displays a
#' single-row message table with minimal UI elements.
#'
#' @param message Explanatory message text displayed in the table cell. Default
#'   provides guidance about why no data is shown. Text can be customized for
#'   specific contexts.
#'
#' @return A DT datatable htmlwidget object with:
#'   - Single row and column containing the message
#'   - No pagination, filtering, or sorting controls (dom = 't')
#'   - No row numbers
#'   - Clean minimal appearance for empty state
#'   
#' @examples
#' \dontrun{
#' # Default message
#' empty_table <- create_empty_table_message()
#' 
#' # Custom message
#' custom_table <- create_empty_table_message(
#'   message = "Please select at least one country or comparator."
#' )
#' }
#'
#' @importFrom DT datatable
#' @importFrom tibble tibble
#'
#' @keywords internal
create_empty_table_message <- function(message = "No data available for the selected country/comparators and criterion.") {
  
  # Create single-row tibble with message
  empty_df <- tibble::tibble(Message = message)
  
  # Create minimal datatable with no controls
  DT::datatable(
    empty_df,
    options = list(
      dom = 't',        # Show only table (no pagination, search, etc.)
      ordering = FALSE  # Disable sorting (irrelevant for single row)
    ),
    rownames = FALSE    # Don't show row numbers
  )
}

#' Create Question Info Icon with Modal
#'
#' Creates an info icon button that opens a modal dialog showing data sources and
#' methodology for a CPIA question. Provides transparency about which publicly
#' available datasets contribute to each question's estimated score.
#'
#' @param ns Namespace function from the calling module (e.g., NS(id))
#' @param input_id ID for the action button (default: "question_info")
#'
#' @return A shiny UI element containing:
#'   - Info icon button (ℹ️) with tooltip
#'   - Styled with bootstrap info color
#'   - No border, transparent background
#'   
#' @examples
#' \dontrun{
#' # In module UI
#' ns <- NS("my_module")
#' create_question_info_icon(ns)
#' }
#'
#' @importFrom shiny actionButton icon modalDialog tags a h4 p hr modalButton
#'
#' @keywords internal
create_question_info_icon <- function(ns, input_id = "question_info") {
  shiny::actionButton(
    ns(input_id),
    label = NULL,
    icon = shiny::icon("circle-info"),
    class = "btn-info btn-sm",
    style = "border: none; background: transparent; color: #0d6efd; padding: 0 5px;",
    title = "View data sources and methodology"
  )
}

#' Create Question Info Modal
#'
#' Creates a modal dialog displaying data sources and indicators for a selected
#' CPIA question. Shows the actual indicators from cpiaetl::metadata_cpia that
#' contribute to the question's score with their descriptions. Links to full 
#' documentation on RPubs.
#'
#' @param question_code The question code (e.g., "q12a")
#' @param question_label The full question label
#' @param indicator_info Tibble with columns: indicator, var_description_short, source
#' @param sources Character vector of data source names
#' @param n_indicators Number of indicators
#' @param documentation_url URL to full documentation (default: RPubs link)
#'
#' @return A shiny modal dialog UI element
#'
#' @examples
#' \dontrun{
#' # In module server
#' observeEvent(input$question_info, {
#'   sources <- get_question_data_sources()
#'   info <- sources[sources$variable == input$question, ]
#'   showModal(create_question_info_modal(
#'     question_code = input$question,
#'     question_label = "Property Rights",
#'     indicator_info = info$indicator_info[[1]],
#'     sources = info$sources[[1]],
#'     n_indicators = info$n_indicators
#'   ))
#' })
#' }
#'
#' @importFrom shiny modalDialog tags a h4 p hr
#'
#' @keywords internal
create_question_info_modal <- function(
    question_code,
    question_label,
    indicator_info,
    sources,
    n_indicators,
    documentation_url = "https://rpubs.com/ifeanyi588/cpiascoringmethod") {
  
  shiny::modalDialog(
    title = shiny::tags$div(
      style = "font-size: 1.2em; font-weight: bold;",
      paste0(toupper(question_code), " - ", question_label)
    ),
    
    shiny::tags$div(
      style = "margin-bottom: 1em;",
      shiny::tags$span(
        style = "background-color: #e7f3ff; padding: 4px 8px; border-radius: 4px; font-size: 0.9em;",
        paste(n_indicators, "indicators from", length(sources), "data sources")
      )
    ),
    
    shiny::h4("Data Sources", style = "margin-top: 0;"),
    shiny::tags$ul(
      lapply(sources, function(source) {
        shiny::tags$li(source)
      })
    ),
    
    shiny::h4("Indicators", style = "margin-top: 1.5em;"),
    shiny::tags$div(
      style = "max-height: 400px; overflow-y: auto;",
      shiny::tags$table(
        class = "table table-striped table-bordered",
        style = "width: 100%; font-size: 0.9em;",
        shiny::tags$thead(
          shiny::tags$tr(
            shiny::tags$th("Indicator", style = "width: 20%;"),
            shiny::tags$th("Description", style = "width: 50%;"),
            shiny::tags$th("Source", style = "width: 30%;")
          )
        ),
        shiny::tags$tbody(
          lapply(seq_len(nrow(indicator_info)), function(i) {
            shiny::tags$tr(
              shiny::tags$td(shiny::tags$code(indicator_info$indicator[i])),
              shiny::tags$td(indicator_info$var_description_short[i]),
              shiny::tags$td(indicator_info$source[i])
            )
          })
        )
      )
    ),
    
    shiny::hr(),
    
    shiny::p(
      style = "margin-bottom: 0;",
      "For complete methodology and technical details, see: ",
      shiny::a(
        "CPIA Scoring Methodology Documentation",
        href = documentation_url,
        target = "_blank",
        style = "font-weight: bold;"
      )
    ),
    
    size = "l",
    easyClose = TRUE,
    footer = shiny::modalButton("Close")
  )
}
