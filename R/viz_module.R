#' Visualization Module UI
#'
#' @param id Module namespace ID
#'
#' @importFrom shiny NS selectInput checkboxInput tagList h4 p
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
      
      # Question selector
      shiny::selectInput(
        ns("question"),
        "CPIA Criterion:",
        choices = c(
          "Q12a - Property Rights & Rule-based Governance" = "q12a",
          "Q12b - Quality of Budgetary & Financial Management" = "q12b",
          "Q12c - Efficiency of Revenue Mobilization" = "q12c",
          "Q13b - Quality of Public Administration" = "q13b",
          "Q15a - Quality of Budgetary & Financial Management" = "q15a",
          "Q15b - Efficiency of Revenue Mobilization" = "q15b",
          "Q15c - Quality of Public Administration" = "q15c",
          "Q16a - Transparency, Accountability & Corruption" = "q16a",
          "Q16b - Quality of Budgetary & Financial Management" = "q16b",
          "Q16c - Efficiency of Revenue Mobilization" = "q16c",
          "Q16d - Quality of Public Administration" = "q16d"
        ),
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

#' Visualization Module Server
#'
#' @param id Module namespace ID
#'
#' @importFrom shiny moduleServer reactive observeEvent updateSelectInput req
#' @importFrom dplyr filter select mutate arrange
#' @importFrom tidyr pivot_longer
#' @importFrom ggplot2 ggplot aes geom_line labs theme_minimal theme element_text
#' @importFrom plotly ggplotly
#' @importFrom DT renderDT datatable
#'
#' @keywords internal
viz_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    
    # Get the dataset based on user selection
    get_data <- shiny::reactive({
      if (input$use_africaii) {
        cpiaetl::africaii_cpia
      } else {
        cpiaetl::standard_cpia
      }
    })
    
    # Get the group dataset based on user selection
    get_group_data <- shiny::reactive({
      if (input$use_africaii) {
        cpiaetl::group_africaii_cpia
      } else {
        cpiaetl::group_standard_cpia
      }
    })
    
    # Initialize choices
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
    })
    
    # Get filtered data for plotting
    plot_data <- shiny::reactive({
      shiny::req(input$country, input$question)
      
      data <- get_data()
      group_data <- get_group_data()
      selected_country <- input$country
      question <- input$question
      
      # Get the selected country's data
      country_data <- data |>
        dplyr::filter(economy == selected_country) |>
        dplyr::select(economy, year = cpia_year, score = !!rlang::sym(question), 
                      region, income_group) |>
        dplyr::filter(!is.na(score)) |>
        dplyr::mutate(
          group_type = "Selected Country",
          display_name = economy,
          line_type = "solid"
        )
      
      comparator_data <- data.frame()
      
      # Get region averages if selected
      if (!is.null(input$selected_regions) && length(input$selected_regions) > 0) {
        region_data <- group_data |>
          dplyr::filter(group %in% input$selected_regions) |>
          dplyr::select(group, year = cpia_year, score = !!rlang::sym(question)) |>
          dplyr::filter(!is.na(score)) |>
          dplyr::mutate(
            economy = group,
            region = group,
            income_group = NA_character_,
            group_type = "Comparator",
            display_name = group,
            line_type = "dashed",
            comparator_category = "region"
          ) |>
          dplyr::select(-group)
        
        comparator_data <- dplyr::bind_rows(comparator_data, region_data)
      }
      
      # Get income group averages if selected
      if (!is.null(input$selected_income_groups) && length(input$selected_income_groups) > 0) {
        income_data <- group_data |>
          dplyr::filter(group %in% input$selected_income_groups) |>
          dplyr::select(group, year = cpia_year, score = !!rlang::sym(question)) |>
          dplyr::filter(!is.na(score)) |>
          dplyr::mutate(
            economy = group,
            region = NA_character_,
            income_group = group,
            group_type = "Comparator",
            display_name = group,
            line_type = "dashed",
            comparator_category = "income_group"
          ) |>
          dplyr::select(-group)
        
        comparator_data <- dplyr::bind_rows(comparator_data, income_data)
      }
      
      # Get custom countries if selected
      if (!is.null(input$custom_countries) && length(input$custom_countries) > 0) {
        custom_data <- data |>
          dplyr::filter(economy %in% input$custom_countries) |>
          dplyr::select(economy, year = cpia_year, score = !!rlang::sym(question), 
                        region, income_group) |>
          dplyr::filter(!is.na(score)) |>
          dplyr::mutate(
            group_type = "Comparator",
            display_name = economy,
            line_type = "dashed",
            comparator_category = "country"
          )
        
        comparator_data <- dplyr::bind_rows(comparator_data, custom_data)
      }
      
      # Combine data
      dplyr::bind_rows(country_data, comparator_data) |>
        dplyr::arrange(year, display_name)
    })
    
    # Create the plot
    output$score_plot <- plotly::renderPlotly({
      shiny::req(plot_data())
      
      data <- plot_data()
      selected_country <- input$country
      
      # Create ggplot
      # Add a size variable for highlighting selected country
      data <- data |>
        dplyr::mutate(
          line_size = ifelse(economy == selected_country, 1.2, 0.8),
          year_factor = factor(year)
        )
      
      p <- ggplot2::ggplot(data, ggplot2::aes(x = year_factor, y = score, 
                                               color = display_name, 
                                               group = display_name,
                                               linetype = line_type,
                                               text = paste0(
                                                 display_name, "<br>",
                                                 "Year: ", year, "<br>",
                                                 "Score: ", round(score, 2)
                                               ))) +
        ggplot2::geom_line(ggplot2::aes(linewidth = line_size)) +
        ggplot2::scale_linewidth_identity() +
        ggplot2::scale_linetype_identity() +
        ggplot2::labs(
          title = paste("CPIA Scores:", input$question),
          x = "Year",
          y = "Estimated Score",
          color = NULL
        ) +
        ggplot2::theme_minimal() +
        ggplot2::theme(
          plot.title = ggplot2::element_text(size = 14, face = "bold"),
          legend.position = "bottom",
          axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)
        )
      
      # Convert to plotly
      plotly::ggplotly(p, tooltip = "text") |>
        plotly::layout(hovermode = "closest")
    })
    
    # Create the data table in wide format
    output$score_table <- DT::renderDT({
      shiny::req(plot_data())
      
      # Standard wide pivot for all data
      data_wide <- plot_data() |>
        dplyr::select(Year = year, Name = display_name, Score = score) |>
        tidyr::pivot_wider(
          names_from = Name,
          values_from = Score
        ) |>
        dplyr::arrange(Year)
      
      DT::datatable(
        data_wide,
        options = list(
          pageLength = 15,
          scrollX = TRUE,
          dom = 'Bfrtip',
          buttons = c('copy', 'csv', 'excel')
        ),
        extensions = 'Buttons',
        rownames = FALSE
      ) |>
        DT::formatRound(columns = 2:ncol(data_wide), digits = 1)
    })
  })
}
