#' Run the CPIA Shiny Application
#'
#' Launches an interactive Shiny dashboard for CPIA data visualization and analysis.
#'
#' @param standard_data Standard CPIA dataset (default: cpiaetl::standard_cpia)
#' @param africaii_data African Integrity Indicators CPIA dataset (default: cpiaetl::africaii_cpia)
#' @param group_standard_data Standard group averages dataset (default: cpiaetl::group_standard_cpia)
#' @param group_africaii_data African Integrity Indicators group averages dataset (default: cpiaetl::group_africaii_cpia)
#' @param ... Additional arguments passed to \code{\link[shiny]{shinyApp}}.
#'
#' @return A Shiny app object.
#'
#' @examples
#' \dontrun{
#' run_cpiaapp()
#' }
#'
#' @importFrom shiny shinyApp addResourcePath icon tags
#' @importFrom bslib page_navbar bs_theme bs_add_rules nav_panel nav_spacer nav_menu nav_item navbar_options font_google
#' @importFrom thematic thematic_shiny
#' @export
run_cpiaapp <- function(standard_data = cpiaetl::standard_cpia,
                        africaii_data = cpiaetl::africaii_cpia,
                        group_standard_data = cpiaetl::group_standard_cpia,
                        group_africaii_data = cpiaetl::group_africaii_cpia,
                        ...) {
  
  # Validate required datasets
  validate_datasets(
    standard_data = standard_data,
    africaii_data = africaii_data,
    group_standard_data = group_standard_data,
    group_africaii_data = group_africaii_data
  )

  # add path to visual assets (image and css)
  shiny::addResourcePath("assets", system.file("www", package = "cpiaapp"))
  thematic::thematic_shiny(font = "auto")

  ui <- bslib::page_navbar(
    title = "CPIA Dashboard",
    fillable = FALSE,

    # set theme
    theme = bslib::bs_theme(
      bootswatch = "litera",
      base_font = bslib::font_google("Source Sans Pro"),
      code_font = bslib::font_google("Source Sans Pro"),
      heading_font = bslib::font_google("Fira Sans"),
      navbar_bg = "#FFFFFF"
    ) |>
      bslib::bs_add_rules(
        readLines(system.file("www/styles.css", package = "cpiaapp"))
      ),

    navbar_options = bslib::navbar_options(
      underline = TRUE
    ),

    padding = "20px",

    # panel 1: home
    bslib::nav_panel(
      "Home",
      icon = shiny::icon("home"),

      # content
      bslib::card(
        bslib::card_header(
          shiny::tags$img(src = "assets/cpia_logo.png", width = "80%")
        ),
        bslib::card_body(
          shiny::tags$br(),
          shiny::tags$h3("Welcome to the CPIA Dashboard"),
          shiny::markdown(
            readLines(system.file("markdown/cpia_home.md", package = "cpiaapp"))
          )
        )
      )
    ),

    # panel 2: Visualizations
    bslib::nav_panel(
      "Visualizations",
      icon = shiny::icon("chart-line"),
      viz_ui("viz")
    ),

    # GitHub code links
    bslib::nav_menu(
      title = "Code",
      icon = shiny::icon("github"),
      bslib::nav_item(
        shiny::tags$a(
          "CPIA Dashboard",
          href = "https://github.com/WB-PIDA-Data-Science-Shop/cpiaapp",
          target = "_blank"
        )
      ),
      bslib::nav_item(
        shiny::tags$a(
          "CPIA ETL Pipeline",
          href = "https://github.com/WB-PIDA-Data-Science-Shop/cpiaetl",
          target = "_blank"
        )
      )
    )
  )

  server <- function(input, output, session){
    viz_server("viz", 
               standard_data = standard_data,
               africaii_data = africaii_data,
               group_standard_data = group_standard_data,
               group_africaii_data = group_africaii_data)
  }

  shiny::shinyApp(ui, server, ...)
}
