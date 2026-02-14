#' Get CPIA Question Metadata
#'
#' Loads and formats CPIA question metadata from the cpiaetl package. This function
#' uses the metadata_cpia dataset which contains question codes, labels, and data
#' source information. Only returns questions that have actual data available in
#' the CPIA datasets.
#'
#' @return A tibble with columns:
#'   - question_code: Question identifier (e.g., "q12a", "q12b")
#'   - question_label: Full question text
#'   - category: Always "Governance" for current questions
#'   - subcategory: Question group (e.g., "Q12", "Q13", "Q15", "Q16")
#'   
#' @examples
#' \dontrun{
#' questions <- get_cpia_questions()
#' # Returns governance questions with available data
#' governance <- questions[questions$category == "Governance", ]
#' }
#'
#' @importFrom tibble tibble
#' @importFrom dplyr distinct arrange .data
#' @importFrom utils read.csv
#'
#' @keywords internal
get_cpia_questions <- function() {
  # Get metadata from cpiaetl which only includes questions with data
  metadata <- cpiaetl::metadata_cpia
  
  # Get unique questions with their labels from cpia_defns
  cpia_defns_path <- system.file("extdata", "cpia_defns.csv", package = "cpiaetl")
  
  # Fail fast if cpiaetl not installed or file missing
  if (cpia_defns_path == "") {
    stop("Cannot find cpia_defns.csv in cpiaetl package. Please ensure cpiaetl is installed.", call. = FALSE)
  }
  
  # Read the CSV file with question metadata
  cpia_defns <- read.csv(cpia_defns_path, stringsAsFactors = FALSE)
  
  # Get unique questions from metadata (only those with data)
  available_questions <- unique(metadata$variable)
  
  # Filter cpia_defns to only include questions with data
  cpia_defns <- cpia_defns[cpia_defns$variable %in% available_questions, ]
  
  # Extract subcategory from question code (e.g., "q12a" -> "Q12")
  subcategory <- toupper(gsub("([a-z]+)([0-9]+).*", "Q\\2", cpia_defns$variable))
  
  # Return standardized tibble format
  result <- tibble::tibble(
    question_code = cpia_defns$variable,      # e.g., "q12a"
    question_label = cpia_defns$subquestion,  # Full text description
    category = "Governance",                  # All current questions are governance
    subcategory = subcategory                 # e.g., "Q12"
  )
  
  # Arrange by question code for consistent ordering
  dplyr::arrange(result, .data$question_code)
}

#' Get Governance CPIA Questions
#'
#' Convenience wrapper that filters CPIA questions to return only governance-related
#' questions (Q12-Q16). Since all current questions in cpiaetl are governance questions,
#' this currently returns the same result as get_cpia_questions(), but provides future
#' flexibility if non-governance questions are added. Only includes questions with
#' available data.
#'
#' @return A tibble with governance questions only. Currently returns all questions
#'   with available data: q12a, q12b, q12c, q13b, q15a, q15b, q15c, q16a, q16b, q16c, q16d.
#'   Same structure as get_cpia_questions().
#'   
#' @examples
#' \dontrun{
#' gov_questions <- get_governance_questions()
#' # Use in Shiny UI
#' format_question_choices(gov_questions)
#' }
#'
#' @keywords internal
get_governance_questions <- function() {
  # Get all questions and filter to governance category
  questions <- get_cpia_questions()
  # Currently all questions are governance, but this provides future flexibility
  questions[questions$category == "Governance", ]
}

#' Format Question Choices for Shiny SelectInput
#'
#' Converts question metadata into a named character vector suitable for shiny::selectInput().
#' The names (display labels) show the question code and full text, while the values
#' are the question codes used for data lookup. This allows users to see readable
#' descriptions while the app uses standardized codes internally.
#'
#' @param questions_df A tibble or data frame with columns \code{question_code} and 
#'   \code{question_label}. Typically from get_governance_questions().
#' @param include_question_code Logical. If TRUE (default), prepends question code 
#'   to label (e.g., "Q12A - Property rights and rule-based governance"). If FALSE,
#'   shows only the label text.
#'
#' @return A named character vector where:
#'   - Names: Display labels shown to users (e.g., "Q12A - Property rights...")
#'   - Values: Question codes for data lookup (e.g., "q12a")
#'   - Empty character vector if input has 0 rows
#'   
#' @examples
#' \dontrun{
#' # Get questions and format for selectInput
#' questions <- get_governance_questions()
#' choices <- format_question_choices(questions)
#' 
#' # Use in Shiny UI
#' selectInput("question", "Select CPIA Criterion:", choices = choices)
#' 
#' # Without question codes
#' choices_clean <- format_question_choices(questions, include_question_code = FALSE)
#' }
#'
#' @importFrom stats setNames
#'
#' @keywords internal
format_question_choices <- function(questions_df, include_question_code = TRUE) {
  # Validate required columns exist
  if (!all(c("question_code", "question_label") %in% names(questions_df))) {
    stop("questions_df must contain 'question_code' and 'question_label' columns")
  }
  
  # Handle empty input
  if (nrow(questions_df) == 0) {
    return(character(0))
  }
  
  # Create user-friendly display labels
  if (include_question_code) {
    # Format: "Q12A - Property rights and rule-based governance"
    labels <- paste0(
      toupper(questions_df$question_code),  # Uppercase for consistency
      " - ", 
      questions_df$question_label
    )
  } else {
    # Format: "Property rights and rule-based governance" (label only)
    labels <- questions_df$question_label
  }
  
  # Create named vector: labels as names, codes as values
  # This allows selectInput to display labels while returning codes
  choices <- setNames(questions_df$question_code, labels)
  
  choices
}

#' Get Data Sources for CPIA Questions
#'
#' Loads mapping of CPIA questions to their underlying data sources from cpiaetl.
#' This provides transparency about which publicly available datasets and indicators
#' contribute to each question's estimated score.
#'
#' @return A tibble with columns:
#'   - question_code: Question identifier (e.g., "q12a")
#'   - indicator_info: List of tibbles with indicator, description, and source
#'   - sources: Character vector of unique data sources for this question
#'   - n_indicators: Number of indicators used
#'   
#' @examples
#' \dontrun{
#' sources <- get_question_data_sources()
#' # Get sources for specific question
#' q12a_sources <- sources[sources$question_code == "q12a", ]
#' }
#'
#' @importFrom tibble tibble
#' @importFrom dplyr group_by summarize n select
#'
#' @keywords internal
get_question_data_sources <- function() {
  # Get metadata from cpiaetl package
  metadata <- cpiaetl::metadata_cpia
  
  # Group by question and aggregate indicators with descriptions and sources
  metadata |>
    dplyr::group_by(variable) |>
    dplyr::summarize(
      indicator_info = list(
        dplyr::pick(indicator, var_description_short, source)
      ),
      sources = list(unique(source)),
      n_indicators = dplyr::n(),
      .groups = "drop"
    ) |>
    tibble::tibble()
}
