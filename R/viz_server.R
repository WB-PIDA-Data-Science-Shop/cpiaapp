#' Visualization Module Server
#'
#' @param id Module namespace ID
#' @param standard_data Standard CPIA dataset (default: cpiaetl::standard_cpia)
#' @param africaii_data African Integrity Indicators CPIA dataset (default: cpiaetl::africaii_cpia)
#' @param group_standard_data Standard group averages dataset (default: cpiaetl::group_standard_cpia)
#' @param group_africaii_data African Integrity Indicators group averages dataset (default: cpiaetl::group_africaii_cpia)
#'
#' @importFrom shiny moduleServer reactive observeEvent updateSelectInput req
#' @importFrom plotly renderPlotly
#' @importFrom DT renderDT
#'
#' @keywords internal
viz_server <- function(id, 
                       standard_data = cpiaetl::standard_cpia,
                       africaii_data = cpiaetl::africaii_cpia,
                       group_standard_data = cpiaetl::group_standard_cpia,
                       group_africaii_data = cpiaetl::group_africaii_cpia) {
  
  # Validate required datasets
  validate_datasets(
    standard_data = standard_data,
    africaii_data = africaii_data,
    group_standard_data = group_standard_data,
    group_africaii_data = group_africaii_data
  )
  
  shiny::moduleServer(id, function(input, output, session) {
    
    # Get the dataset based on user selection
    get_data <- shiny::reactive({
      if (input$use_africaii) {
        africaii_data
      } else {
        standard_data
      }
    })
    
    # Get the group dataset based on user selection
    get_group_data <- shiny::reactive({
      if (input$use_africaii) {
        group_africaii_data
      } else {
        group_standard_data
      }
    })
    
    # Initialize choices only once on startup
    shiny::observeEvent(get_data(), {
      data <- get_data()
      group_data <- get_group_data()
      
      countries <- sort(unique(data$economy))
      regions <- sort(unique(group_data$group[group_data$group_type == "Region"]))
      income_groups <- sort(unique(group_data$group[group_data$group_type == "Income Group"]))
      
      shiny::updateSelectInput(
        session,
        "country",
        choices = countries,
        selected = countries[1]
      )
      
      shiny::updateSelectInput(
        session,
        "selected_regions",
        choices = regions
      )
      
      shiny::updateSelectInput(
        session,
        "selected_income_groups",
        choices = income_groups
      )
      
      shiny::updateSelectInput(
        session,
        "custom_countries",
        choices = countries
      )
    }, once = TRUE)
    
    # Get filtered data for plotting
    plot_data <- shiny::reactive({
      shiny::req(input$country, input$question)
      
      prepare_plot_data(
        data = get_data(),
        group_data = get_group_data(),
        selected_country = input$country,
        question = input$question,
        selected_regions = input$selected_regions,
        selected_income_groups = input$selected_income_groups,
        custom_countries = input$custom_countries
      )
    })
    
    # Create the plot
    output$score_plot <- plotly::renderPlotly({
      shiny::req(plot_data())
      
      data <- plot_data()
      
      # Check if there's any data to plot
      if (nrow(data) == 0) {
        create_empty_plot_message()
      } else {
        create_cpia_plot(
          data = data,
          selected_country = input$country,
          question = input$question
        )
      }
    })
    
    # Create the data table in wide format
    output$score_table <- DT::renderDT({
      shiny::req(plot_data())
      
      data <- plot_data()
      
      # Check if there's any data
      if (nrow(data) == 0) {
        create_empty_table_message()
      } else {
        create_cpia_table(data)
      }
    })
  })
}
