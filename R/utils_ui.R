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
