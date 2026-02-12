#' Add Plot Styling Columns
#'
#' Adds visual styling attributes to the data for plot differentiation. The selected
#' country gets a thicker line (1.2) to stand out from comparators (0.8). Year is
#' converted to factor for proper categorical x-axis ordering.
#'
#' @param data Prepared plot data from prepare_plot_data() with year, economy, score columns
#' @param selected_country Country name to highlight with thicker line
#'
#' @return A tibble with two additional columns:
#'   - line_size: 1.2 for selected country, 0.8 for all comparators
#'   - year_factor: Year converted to factor for proper axis ordering
#'   
#' @examples
#' \dontrun{
#' plot_data <- prepare_plot_data(...)
#' styled_data <- add_plot_styling_columns(plot_data, "Kenya")
#' }
#'
#' @importFrom dplyr mutate
#'
#' @keywords internal
add_plot_styling_columns <- function(data, selected_country) {
  data |>
    dplyr::mutate(
      # Thicker line for selected country to make it stand out visually
      line_size = ifelse(economy == selected_country, 1.2, 0.8),
      # Convert year to factor for proper categorical x-axis in ggplot
      year_factor = factor(year)
    )
}

#' Create Base CPIA Score Plot
#'
#' Creates the foundational ggplot object with line geometries and custom tooltips.
#' This function sets up the basic plot structure without themes or labels. The plot
#' uses color to distinguish entities, linetype (solid/dashed) to distinguish the
#' selected country from comparators, and line width for emphasis.
#'
#' @param data Prepared and styled plot data with columns: year_factor, score, 
#'   display_name, line_type, line_size
#' @param question Question code (e.g., "q12a") used in tooltip context
#'
#' @return A ggplot object with geom_line, color aesthetics, and custom hover text.
#'   Scales use identity mapping for linetype and linewidth to respect data values.
#'   
#' @examples
#' \dontrun{
#' styled_data <- add_plot_styling_columns(plot_data, "Kenya")
#' base_plot <- create_base_cpia_plot(styled_data, "q12b")
#' }
#'
#' @importFrom ggplot2 ggplot aes geom_line scale_linewidth_identity scale_linetype_identity
#'
#' @keywords internal
create_base_cpia_plot <- function(data, question) {
  ggplot2::ggplot(
    data, 
    ggplot2::aes(
      x = year_factor,        # Categorical year for proper x-axis
      y = score,              # CPIA score (typically 1-6 scale)
      color = display_name,   # Different color for each entity
      group = display_name,   # Group by entity for line connections
      linetype = line_type,   # solid for selected, dashed for comparators
      # Custom tooltip text for plotly interactivity
      text = paste0(
        display_name, "<br>",
        "Year: ", year, "<br>",
        "Score: ", round(score, 2)
      )
    )
  ) +
    # Draw lines with variable width (thicker for selected country)
    ggplot2::geom_line(ggplot2::aes(linewidth = line_size)) +
    # Use actual values from data for linewidth (no scaling)
    ggplot2::scale_linewidth_identity() +
    # Use actual values from data for linetype (no scaling)
    ggplot2::scale_linetype_identity()
}

#' Style CPIA Plot
#'
#' Applies theme, labels, and visual styling to the CPIA plot. Uses theme_minimal()
#' for clean aesthetics, positions legend at bottom for better readability, and
#' rotates x-axis labels 45° to prevent overlapping year labels.
#'
#' @param plot A ggplot object from create_base_cpia_plot()
#' @param question Question code for title (e.g., "q12a")
#'
#' @return A styled ggplot object with theme, labels, and layout applied.
#'   Ready for conversion to plotly or direct rendering.
#'   
#' @examples
#' \dontrun{
#' base_plot <- create_base_cpia_plot(styled_data, "q12b")
#' styled_plot <- style_cpia_plot(base_plot, "q12b")
#' }
#'
#' @importFrom ggplot2 labs theme_minimal theme element_text
#'
#' @keywords internal
style_cpia_plot <- function(plot, question) {
  plot +
    # Add descriptive labels
    ggplot2::labs(
      title = paste("CPIA Scores:", question),
      x = "Year",
      y = "Estimated Score",
      color = NULL  # Remove legend title for cleaner look
    ) +
    # Apply minimal theme for clean, modern appearance
    ggplot2::theme_minimal() +
    # Customize specific theme elements
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 14, face = "bold"),
      legend.position = "bottom",  # Bottom legend for better space usage
      legend.text = ggplot2::element_text(size = 11),  # Larger legend labels for readability
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)  # Angled labels prevent overlap
    )
}

#' Convert CPIA Plot to Interactive Plotly
#'
#' Converts a static ggplot object to an interactive plotly visualization. The 
#' conversion enables hover tooltips, zooming, panning, and other interactive features.
#' Hover mode is set to "closest" so users can easily inspect individual data points.
#'
#' @param plot A styled ggplot object from style_cpia_plot()
#'
#' @return A plotly htmlwidget object with interactive features enabled.
#'   The custom "text" aesthetic from ggplot is used for hover tooltips.
#'   
#' @examples
#' \dontrun{
#' styled_plot <- style_cpia_plot(base_plot, "q12b")
#' interactive_plot <- convert_to_plotly(styled_plot)
#' }
#'
#' @importFrom plotly ggplotly layout
#'
#' @keywords internal
convert_to_plotly <- function(plot) {
  # Convert ggplot to plotly, using custom "text" aesthetic for tooltips
  plotly::ggplotly(plot, tooltip = "text") |>
    # Configure hover behavior: show nearest point's tooltip
    plotly::layout(hovermode = "closest")
}

#' Create Complete CPIA Score Plot
#'
#' Main orchestrator function that creates a complete interactive CPIA score plot.
#' This function coordinates the full plotting pipeline: styling → base plot → 
#' theme application → interactive conversion. The resulting plot shows time-series
#' data with the selected country highlighted (solid, thick line) and comparators
#' shown with dashed, thinner lines.
#'
#' @param data Prepared plot data from prepare_plot_data() with columns: year,
#'   economy, score, display_name, line_type, group_type
#' @param selected_country Country name to highlight with solid, thick line
#' @param question Question code (e.g., "q12a", "q12b") for plot title
#'
#' @return A plotly htmlwidget object ready for rendering in Shiny with:
#'   - Interactive hover tooltips showing entity name, year, and score
#'   - Zoom and pan capabilities
#'   - Color-coded lines for different entities
#'   - Visual distinction between selected country (solid/thick) and comparators (dashed/thin)
#'   
#' @examples
#' \dontrun{
#' # Prepare data with country and regional comparators
#' plot_data <- prepare_plot_data(
#'   data = cpiaetl::standard_cpia,
#'   group_data = cpiaetl::group_standard_cpia,
#'   selected_country = "Kenya",
#'   question = "q12b",
#'   selected_regions = c("Africa (AFR)")
#' )
#' 
#' # Create interactive plot
#' plot <- create_cpia_plot(plot_data, "Kenya", "q12b")
#' }
#'
#' @keywords internal
create_cpia_plot <- function(data, selected_country, question) {
  # Step 1: Add visual styling attributes (line size, year as factor)
  styled_data <- add_plot_styling_columns(data, selected_country)
  
  # Step 2: Create base ggplot with lines and aesthetics
  base_plot <- create_base_cpia_plot(styled_data, question)
  
  # Step 3: Apply theme, labels, and layout
  styled_plot <- style_cpia_plot(base_plot, question)
  
  # Step 4: Convert to interactive plotly visualization
  convert_to_plotly(styled_plot)
}
