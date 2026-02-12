#' Visualization Module UI
#'
#' @param id Module namespace ID
#'
#' @importFrom shiny NS selectInput checkboxInput tagList h4 p hr
#' @importFrom bslib card card_header card_body layout_sidebar sidebar
#' @importFrom plotly plotlyOutput
#' @importFrom DT DTOutput
#'
#' @keywords internal
viz_ui <- function(id) {
  ns <- shiny::NS(id)
  
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      width = 300,
      
      shiny::h4("Data Selection"),
      
      # Question selector - dynamically generated from metadata
      shiny::selectInput(
        ns("question"),
        "CPIA Criterion:",
        choices = format_question_choices(get_governance_questions()),
        selected = "q12b"
      ),
      
      # Country selector
      shiny::selectInput(
        ns("country"),
        "Select Country:",
        choices = NULL,  # Will be populated in server
        selected = NULL
      ),
      
      shiny::hr(),
      
      shiny::h4("Comparators"),
      
      # Region selector
      shiny::selectInput(
        ns("selected_regions"),
        "Regions:",
        choices = NULL,
        multiple = TRUE
      ),
      
      # Income group selector
      shiny::selectInput(
        ns("selected_income_groups"),
        "Income Groups:",
        choices = NULL,
        multiple = TRUE
      ),
      
      # Custom country selector
      shiny::selectInput(
        ns("custom_countries"),
        "Countries:",
        choices = NULL,
        multiple = TRUE
      ),
      
      shiny::hr(),
      
      # Dataset toggle
      shiny::checkboxInput(
        ns("use_africaii"),
        "Use African Integrity Indicators (Africa only)",
        value = FALSE
      ),
      
      shiny::p(
        style = "font-size: 0.9em; color: #666;",
        "Toggle on to include African Integrity Index data for African countries."
      )
    ),
    
    # Main content area
    bslib::card(
      bslib::card_header("Estimated CPIA Scores Over Time"),
      bslib::card_body(
        plotly::plotlyOutput(ns("score_plot"), height = "500px")
      )
    ),
    
    bslib::card(
      bslib::card_header("Data Table"),
      bslib::card_body(
        DT::DTOutput(ns("score_table"))
      )
    )
  )
}
