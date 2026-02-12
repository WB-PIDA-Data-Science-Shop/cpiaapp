#' Validate CPIA Datasets
#'
#' Validates that all required datasets are present and are valid data frames.
#' Throws an error if any dataset is NULL or not a data frame.
#'
#' @param standard_data Standard CPIA dataset
#' @param africaii_data African Integrity Indicators CPIA dataset
#' @param group_standard_data Standard group averages dataset
#' @param group_africaii_data African Integrity Indicators group averages dataset
#'
#' @return NULL (invisible). Function is called for its side effects (error throwing).
#'
#' @examples
#' \dontrun{
#' validate_datasets(
#'   standard_data = cpiaetl::standard_cpia,
#'   africaii_data = cpiaetl::africaii_cpia,
#'   group_standard_data = cpiaetl::group_standard_cpia,
#'   group_africaii_data = cpiaetl::group_africaii_cpia
#' )
#' }
#'
#' @importFrom utils head
#'
#' @keywords internal
validate_datasets <- function(standard_data, 
                              africaii_data, 
                              group_standard_data, 
                              group_africaii_data) {
  
  # Create named list of datasets to validate
  datasets <- list(
    standard_data = standard_data,
    africaii_data = africaii_data,
    group_standard_data = group_standard_data,
    group_africaii_data = group_africaii_data
  )
  
  # Define required columns for country-level datasets
  country_required_cols <- c("economy", "cpia_year", "region", "income_group")
  
  # Define required columns for group-level datasets
  group_required_cols <- c("group", "cpia_year", "group_type")
  
  # Validate each dataset using functional approach
  # This eliminates repetitive validation blocks
  for (name in names(datasets)) {
    dataset <- datasets[[name]]
    
    # Check if dataset exists and is a data frame
    if (is.null(dataset) || !is.data.frame(dataset)) {
      stop(sprintf("%s must be a valid data frame", name), call. = FALSE)
    }
    
    # Check for required columns based on dataset type
    required_cols <- if (grepl("group_", name)) {
      group_required_cols
    } else {
      country_required_cols
    }
    
    missing_cols <- setdiff(required_cols, names(dataset))
    if (length(missing_cols) > 0) {
      stop(
        sprintf(
          "%s is missing required columns: %s\nExpected columns: %s\nFound columns: %s",
          name,
          paste(missing_cols, collapse = ", "),
          paste(required_cols, collapse = ", "),
          paste(head(names(dataset), 10), collapse = ", ")
        ),
        call. = FALSE
      )
    }
    
    # Check for at least one question column (q12a, q12b, etc.)
    question_cols <- grep("^q\\d+[a-z]?$", names(dataset), value = TRUE)
    if (length(question_cols) == 0) {
      stop(
        sprintf(
          "%s has no question columns (expected columns like q12a, q12b, etc.)\nFound columns: %s",
          name,
          paste(head(names(dataset), 10), collapse = ", ")
        ),
        call. = FALSE
      )
    }
  }
  
  invisible(NULL)
}
