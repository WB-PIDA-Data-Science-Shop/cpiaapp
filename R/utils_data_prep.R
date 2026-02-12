#' Prepare Country Data for Plotting
#'
#' Extracts and formats data for the selected country with visual styling attributes.
#' The selected country gets a solid line to distinguish it from comparators.
#'
#' @param data CPIA dataset (Standard or African Integrity Indicators data)
#' @param selected_country Country name to extract
#' @param question Question column name (e.g., "q12a")
#'
#' @return A tibble with columns: economy, year, score, region, income_group, 
#'   group_type, display_name, line_type. Rows with NA scores are excluded.
#'   
#' @examples
#' \dontrun{
#' prepare_country_data(cpiaetl::standard_cpia, "Kenya", "q12b")
#' }
#'
#' @importFrom dplyr filter select mutate .data
#' @importFrom tibble tibble
#'
#' @keywords internal
prepare_country_data <- function(data, selected_country, question) {
  # Validate question parameter exists in data
  if (!question %in% names(data)) {
    available_questions <- grep("^q\\d+[a-z]?$", names(data), value = TRUE)
    stop(
      sprintf(
        "Question '%s' not found in data.\nAvailable questions: %s",
        question,
        paste(available_questions, collapse = ", ")
      ),
      call. = FALSE
    )
  }
  
  data |>
    # Filter to selected country only
    dplyr::filter(economy == selected_country) |>
    # Select and rename columns, dynamically select question column
    dplyr::select(
      economy, 
      year = cpia_year, 
      score = dplyr::all_of(question),  # Use all_of() for dynamic column selection
      region, 
      income_group
    ) |>
    # Remove rows with missing scores
    dplyr::filter(!is.na(score)) |>
    # Add metadata for plotting: selected country uses solid line
    dplyr::mutate(
      group_type = "Selected Country",
      display_name = economy,
      line_type = "solid"  # Visual distinction from comparators
    )
}

#' Prepare Group Comparator Data (Internal Helper)
#'
#' Internal helper that extracts group average data (regions or income groups) from
#' the group dataset. This function consolidates the common logic used by both
#' prepare_region_comparators() and prepare_income_comparators() to eliminate code
#' duplication. Returns empty tibble if no groups are selected.
#'
#' @param group_data Group averages dataset (Standard or African Integrity Indicators data)
#' @param selected_groups Vector of group names (regions or income groups)
#' @param question Question column name (e.g., "q12a")
#' @param category_type Either "region" or "income_group" to identify comparator type
#'
#' @return A tibble with columns: economy, year, score, region, income_group, group_type,
#'   display_name, line_type, comparator_category. Empty tibble if no groups selected.
#'
#' @importFrom dplyr filter select mutate all_of
#' @importFrom tibble tibble
#'
#' @keywords internal
prepare_group_comparators <- function(group_data, selected_groups, question, category_type) {
  # Early return if no groups selected - avoids unnecessary processing
  if (is.null(selected_groups) || length(selected_groups) == 0) {
    return(tibble::tibble())
  }
  
  # Validate question parameter exists in data
  if (!question %in% names(group_data)) {
    available_questions <- grep("^q\\d+[a-z]?$", names(group_data), value = TRUE)
    stop(
      sprintf(
        "Question '%s' not found in group data.\nAvailable questions: %s",
        question,
        paste(available_questions, collapse = ", ")
      ),
      call. = FALSE
    )
  }
  
  group_data |>
    # Filter to selected groups only
    dplyr::filter(group %in% selected_groups) |>
    # Select and rename columns
    dplyr::select(group, year = cpia_year, score = dplyr::all_of(question)) |>
    # Remove rows with missing scores
    dplyr::filter(!is.na(score)) |>
    # Add metadata: groups shown as dashed lines (comparators)
    # Use category_type to determine which column gets the group name
    dplyr::mutate(
      economy = group,        # Rename for consistency with country data
      region = if (category_type == "region") group else NA_character_,
      income_group = if (category_type == "income_group") group else NA_character_,
      group_type = "Comparator",
      display_name = group,   # Used in legend and tooltips
      line_type = "dashed",   # Visual distinction from selected country
      comparator_category = category_type  # Track type of comparator
    ) |>
    # Remove temporary group column
    dplyr::select(-group)
}

#' Prepare Region Comparator Data
#'
#' Extracts regional average data for selected regions. Regional averages are displayed
#' as dashed lines to distinguish them from the selected country. Returns empty tibble
#' if no regions are selected. This function is a thin wrapper around the internal
#' prepare_group_comparators() helper.
#'
#' @param group_data Group averages dataset (Standard or African Integrity Indicators data)
#' @param selected_regions Vector of region names (e.g., "Africa (AFR)", "East Asia & Pacific (EAP)")
#' @param question Question column name (e.g., "q12a")
#'
#' @return A tibble with columns: economy, year, score, region, income_group, group_type,
#'   display_name, line_type, comparator_category. Empty tibble if no regions selected.
#'   
#' @examples
#' \dontrun{
#' prepare_region_comparators(cpiaetl::group_standard_cpia, c("Africa (AFR)"), "q12b")
#' }
#'
#' @keywords internal
prepare_region_comparators <- function(group_data, selected_regions, question) {
  prepare_group_comparators(group_data, selected_regions, question, "region")
}

#' Prepare Income Group Comparator Data
#'
#' Extracts income group average data for selected income groups. Income groups are 
#' displayed as dashed lines to distinguish them from the selected country. Returns 
#' empty tibble if no income groups are selected. This function is a thin wrapper 
#' around the internal prepare_group_comparators() helper.
#'
#' @param group_data Group averages dataset (Standard or African Integrity Indicators data)
#' @param selected_income_groups Vector of income group names (e.g., "Low income", "Lower middle income")
#' @param question Question column name (e.g., "q12a")
#'
#' @return A tibble with columns: economy, year, score, region, income_group, group_type,
#'   display_name, line_type, comparator_category. Empty tibble if no groups selected.
#'   
#' @examples
#' \dontrun{
#' prepare_income_comparators(cpiaetl::group_standard_cpia, c("Low income"), "q12b")
#' }
#'
#' @keywords internal
prepare_income_comparators <- function(group_data, selected_income_groups, question) {
  prepare_group_comparators(group_data, selected_income_groups, question, "income_group")
}

#' Prepare Custom Country Comparator Data
#'
#' Extracts data for user-selected custom countries. These countries are displayed
#' as dashed lines to distinguish them from the main selected country. Returns empty
#' tibble if no custom countries are selected.
#'
#' @param data CPIA dataset (Standard or African Integrity Indicators data)
#' @param custom_countries Vector of country names (e.g., c("Kenya", "Tanzania"))
#' @param question Question column name (e.g., "q12a")
#'
#' @return A tibble with columns: economy, year, score, region, income_group, group_type,
#'   display_name, line_type, comparator_category. Empty tibble if no countries selected.
#'   
#' @examples
#' \dontrun{
#' prepare_country_comparators(cpiaetl::standard_cpia, c("Kenya", "Tanzania"), "q12b")
#' }
#'
#' @importFrom dplyr filter select mutate all_of
#' @importFrom tibble tibble
#'
#' @keywords internal
prepare_country_comparators <- function(data, custom_countries, question) {
  # Early return if no custom countries selected
  if (is.null(custom_countries) || length(custom_countries) == 0) {
    return(tibble::tibble())
  }
  
  # Validate question parameter exists in data
  if (!question %in% names(data)) {
    available_questions <- grep("^q\\d+[a-z]?$", names(data), value = TRUE)
    stop(
      sprintf(
        "Question '%s' not found in data.\nAvailable questions: %s",
        question,
        paste(available_questions, collapse = ", ")
      ),
      call. = FALSE
    )
  }
  
  data |>
    # Filter to selected custom countries
    dplyr::filter(economy %in% custom_countries) |>
    # Select and rename columns
    dplyr::select(
      economy, 
      year = cpia_year, 
      score = dplyr::all_of(question),  # Dynamic column selection with all_of()
      region, 
      income_group
    ) |>
    # Remove rows with missing scores
    dplyr::filter(!is.na(score)) |>
    # Add metadata: custom countries shown as dashed lines (comparators)
    dplyr::mutate(
      group_type = "Comparator",
      display_name = economy,         # Country name for legend/tooltips
      line_type = "dashed",           # Visual distinction from selected country
      comparator_category = "country" # Track type of comparator
    )
}

#' Prepare Complete Plot Data
#'
#' Main orchestrator function that combines selected country data with all requested
#' comparators (regions, income groups, custom countries). This function delegates to
#' specialized helper functions for each data type and combines the results into a
#' unified dataset ready for plotting. The selected country gets a solid line while
#' all comparators get dashed lines.
#'
#' @param data CPIA dataset (Standard or African Integrity Indicators data)
#' @param group_data Group averages dataset (Standard or African Integrity Indicators data)
#' @param selected_country Country name to highlight with solid line
#' @param question Question column name (e.g., "q12a", "q12b", etc.)
#' @param selected_regions Vector of region names (optional, defaults to NULL)
#' @param selected_income_groups Vector of income group names (optional, defaults to NULL)
#' @param custom_countries Vector of custom country names (optional, defaults to NULL)
#'
#' @return A tibble with columns: economy, year, score, display_name, line_type, 
#'   group_type, region, income_group, comparator_category (where applicable).
#'   Arranged chronologically by year, then alphabetically by display_name.
#'   Empty comparator selections return only the selected country data.
#'   
#' @examples
#' \dontrun{
#' # With regions and custom countries
#' prepare_plot_data(
#'   data = cpiaetl::standard_cpia,
#'   group_data = cpiaetl::group_standard_cpia,
#'   selected_country = "Kenya",
#'   question = "q12b",
#'   selected_regions = c("Africa (AFR)"),
#'   custom_countries = c("Tanzania", "Uganda")
#' )
#' }
#'
#' @importFrom dplyr bind_rows arrange
#'
#' @keywords internal
prepare_plot_data <- function(data, 
                              group_data,
                              selected_country,
                              question,
                              selected_regions = NULL,
                              selected_income_groups = NULL,
                              custom_countries = NULL) {
  
  # Step 1: Get selected country data (solid line, highlighted)
  country_data <- prepare_country_data(data, selected_country, question)
  
  # Step 2: Get all comparator data (dashed lines)
  # Each function returns empty tibble if selection is NULL/empty
  region_data <- prepare_region_comparators(group_data, selected_regions, question)
  income_data <- prepare_income_comparators(group_data, selected_income_groups, question)
  custom_data <- prepare_country_comparators(data, custom_countries, question)
  
  # Step 3: Combine all data sources into single dataset
  # bind_rows() handles empty tibbles gracefully
  dplyr::bind_rows(
    country_data,
    region_data,
    income_data,
    custom_data
  ) |>
    # Sort for consistent plotting: chronological by year, then alphabetical
    dplyr::arrange(year, display_name)
}
