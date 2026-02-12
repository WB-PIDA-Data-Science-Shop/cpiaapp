#' Prepare Table Data for Display
#'
#' Transforms long-format plot data into wide-format table suitable for tabular display.
#' Each row represents a year, and each column represents a country/group. This format
#' is easier for users to compare scores across entities at a glance. Handles duplicate
#' Year/Name combinations by taking the mean (though duplicates shouldn't occur in
#' properly prepared data).
#'
#' @param data Prepared plot data from prepare_plot_data() with columns: year,
#'   display_name, score (long format)
#'
#' @return A tibble in wide format with structure:
#'   - First column: Year (integer)
#'   - Subsequent columns: Entity names (countries/groups) with score values
#'   - Arranged chronologically by Year
#'   - Duplicate Year/Name combinations are averaged (defensive programming)
#'   
#' @examples
#' \dontrun{
#' plot_data <- prepare_plot_data(...)
#' wide_data <- prepare_table_data(plot_data)
#' # Result:
#' # Year | Kenya | Tanzania | Africa (AFR)
#' # 2020 | 3.5   | 3.2      | 3.4
#' # 2021 | 3.6   | 3.3      | 3.5
#' }
#'
#' @importFrom dplyr select arrange distinct
#' @importFrom tidyr pivot_wider
#'
#' @keywords internal
prepare_table_data <- function(data) {
  data |>
    # Select and rename columns for table display
    dplyr::select(Year = year, Name = display_name, Score = score) |>
    # Remove duplicate Year/Name combinations (defensive: shouldn't happen)
    dplyr::distinct(Year, Name, .keep_all = TRUE) |>
    # Transform from long to wide format: Years × Entities
    tidyr::pivot_wider(
      names_from = Name,    # Entity names become column headers
      values_from = Score,  # Scores fill the cells
      values_fn = mean      # If duplicates remain, take mean (shouldn't happen)
    ) |>
    # Sort chronologically for intuitive reading
    dplyr::arrange(Year)
}

#' Create CPIA Score Data Table
#'
#' Main orchestrator function that creates a formatted interactive data table with
#' export capabilities. This function handles the full table generation pipeline:
#' data transformation → DT datatable creation → formatting. The resulting table
#' allows users to export data to Excel/CSV, sort columns, and paginate through years.
#'
#' @param data Plot data from prepare_plot_data() in long format. Will be automatically
#'   transformed to wide format internally via prepare_table_data().
#'
#' @return A DT datatable htmlwidget object with:
#'   - Wide format display (years × entities)
#'   - Export buttons (copy to clipboard, CSV, Excel)
#'   - Horizontal scrolling for many columns
#'   - 15 rows per page (paginated)
#'   - Scores rounded to 1 decimal place
#'   - No row names displayed
#'   
#' @examples
#' \dontrun{
#' # Prepare data with multiple entities
#' plot_data <- prepare_plot_data(
#'   data = cpiaetl::standard_cpia,
#'   group_data = cpiaetl::group_standard_cpia,
#'   selected_country = "Kenya",
#'   question = "q12b",
#'   selected_regions = c("Africa (AFR)")
#' )
#' 
#' # Create interactive table
#' table <- create_cpia_table(plot_data)
#' }
#'
#' @importFrom DT datatable formatRound
#'
#' @keywords internal
create_cpia_table <- function(data) {
  # Step 1: Transform long format data to wide format (Years × Entities)
  table_data <- prepare_table_data(data)
  
  # Step 2: Create DT datatable with interactive features
  dt <- DT::datatable(
    table_data,
    options = list(
      pageLength = 15,     # Show 15 years per page
      scrollX = TRUE,      # Enable horizontal scroll for many columns
      dom = 'Bfrtip',      # Layout: Buttons, filter, table, info, pagination
      buttons = c('copy', 'csv', 'excel')  # Export functionality
    ),
    extensions = 'Buttons',  # Enable export button extensions
    rownames = FALSE         # Don't show row numbers
  )
  
  # Step 3: Apply numeric formatting to score columns (skip Year column)
  # Round all scores to 1 decimal place for readability
  if (ncol(table_data) > 1) {
    dt <- DT::formatRound(dt, columns = 2:ncol(table_data), digits = 1)
  }
  
  dt
}
