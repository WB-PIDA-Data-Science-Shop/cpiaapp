# report_module.R — AI report module combiner
#
# Pairs report_ui() and report_server() following the same pattern as
# viz_module.R. This is the intended entry point for embedding the report
# panel into the cpiaapp dashboard.


#' AI Report Module
#'
#' @title Report Module
#'
#' @description
#' Convenience wrapper that pairs `report_ui()` and `report_server()` into a
#' single callable function, following the same pattern as `viz_module.R`.
#'
#' Call `report_ui(id)` inside the app UI and `report_module()` inside the
#' app server to wire up the full report panel.
#'
#' @param id Character. The Shiny module namespace ID. Must match the `id`
#'   passed to `report_ui()`.
#' @param country Reactive expression returning the selected country name.
#' @param question Reactive expression returning the selected question code.
#' @param question_label Reactive expression returning the human-readable
#'   question label.
#' @param plot_data Reactive expression returning the prepared plot data frame,
#'   as produced by `prepare_plot_data()`.
#'
#' @return Called for side effects only.
#'
#' @examples
#' \dontrun{
#' # In app server:
#' report_module(
#'   id             = "report",
#'   country        = reactive(input$country),
#'   question       = reactive(input$question),
#'   question_label = reactive(question_label()),
#'   plot_data      = plot_data
#' )
#' }
#'
#' @keywords internal
report_module <- function(id, country, question, question_label, plot_data) {
  report_server(
    id             = id,
    country        = country,
    question       = question,
    question_label = question_label,
    plot_data      = plot_data
  )
}
