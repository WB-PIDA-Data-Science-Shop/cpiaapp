test_that("validate_datasets passes with valid data frames", {
  df1 <- tibble::tibble(
    economy = "Kenya",
    cpia_year = 2020,
    region = "Africa",
    income_group = "Lower middle",
    q12a = 3.5,
    q12b = 3.6
  )
  df2 <- tibble::tibble(
    economy = "Tanzania",
    cpia_year = 2020,
    region = "Africa",
    income_group = "Lower middle",
    q12a = 3.2,
    q12b = 3.3
  )
  df3 <- tibble::tibble(
    group = "Africa",
    cpia_year = 2020,
    group_type = "Region",
    q12a = 3.4,
    q12b = 3.5
  )
  df4 <- tibble::tibble(
    group = "Low income",
    cpia_year = 2020,
    group_type = "Income Group",
    q12a = 3.3,
    q12b = 3.4
  )
  
  # Should not throw error
  expect_silent(
    validate_datasets(df1, df2, df3, df4)
  )
  
  # Should return NULL invisibly
  result <- validate_datasets(df1, df2, df3, df4)
  expect_null(result)
})

test_that("validate_datasets errors when standard_data is NULL", {
  df <- tibble::tibble(x = 1:3)
  
  expect_error(
    validate_datasets(NULL, df, df, df),
    "standard_data must be a valid data frame"
  )
})

test_that("validate_datasets errors when standard_data is not a data frame", {
  df <- tibble::tibble(x = 1:3)
  
  expect_error(
    validate_datasets("not a df", df, df, df),
    "standard_data must be a valid data frame"
  )
  
  expect_error(
    validate_datasets(list(x = 1:3), df, df, df),
    "standard_data must be a valid data frame"
  )
})

test_that("validate_datasets errors when africaii_data is NULL", {
  country_df <- tibble::tibble(
    economy = "Country A",
    cpia_year = 2020,
    region = "Africa",
    income_group = "LIC",
    q12a = 3.0
  )
  group_df <- tibble::tibble(
    group = "Africa",
    cpia_year = 2020,
    group_type = "Region",
    q12a = 3.4
  )
  
  expect_error(
    validate_datasets(country_df, NULL, group_df, group_df),
    "africaii_data must be a valid data frame"
  )
})

test_that("validate_datasets errors when africaii_data is not a data frame", {
  country_df <- tibble::tibble(
    economy = "Country A",
    cpia_year = 2020,
    region = "Africa",
    income_group = "LIC",
    q12a = 3.0
  )
  group_df <- tibble::tibble(
    group = "Africa",
    cpia_year = 2020,
    group_type = "Region",
    q12a = 3.4
  )
  
  expect_error(
    validate_datasets(country_df, "not a df", group_df, group_df),
    "africaii_data must be a valid data frame"
  )
})

test_that("validate_datasets errors when group_standard_data is NULL", {
  country_df <- tibble::tibble(
    economy = "Country A",
    cpia_year = 2020,
    region = "Africa",
    income_group = "LIC",
    q12a = 3.0
  )
  group_df <- tibble::tibble(
    group = "Africa",
    cpia_year = 2020,
    group_type = "Region",
    q12a = 3.4
  )
  
  expect_error(
    validate_datasets(country_df, country_df, NULL, group_df),
    "group_standard_data must be a valid data frame"
  )
})

test_that("validate_datasets errors when group_standard_data is not a data frame", {
  country_df <- tibble::tibble(
    economy = "Country A",
    cpia_year = 2020,
    region = "Africa",
    income_group = "LIC",
    q12a = 3.0
  )
  group_df <- tibble::tibble(
    group = "Africa",
    cpia_year = 2020,
    group_type = "Region",
    q12a = 3.4
  )
  
  expect_error(
    validate_datasets(country_df, country_df, 123, group_df),
    "group_standard_data must be a valid data frame"
  )
})

test_that("validate_datasets errors when group_africaii_data is NULL", {
  country_df <- tibble::tibble(
    economy = "Country A",
    cpia_year = 2020,
    region = "Africa",
    income_group = "LIC",
    q12a = 3.0
  )
  group_df <- tibble::tibble(
    group = "Africa",
    cpia_year = 2020,
    group_type = "Region",
    q12a = 3.4
  )
  
  expect_error(
    validate_datasets(country_df, country_df, group_df, NULL),
    "group_africaii_data must be a valid data frame"
  )
})

test_that("validate_datasets errors when group_africaii_data is not a data frame", {
  country_df <- tibble::tibble(
    economy = "Country A",
    cpia_year = 2020,
    region = "Africa",
    income_group = "LIC",
    q12a = 3.0
  )
  group_df <- tibble::tibble(
    group = "Africa",
    cpia_year = 2020,
    group_type = "Region",
    q12a = 3.4
  )
  
  expect_error(
    validate_datasets(country_df, country_df, group_df, c(1, 2, 3)),
    "group_africaii_data must be a valid data frame"
  )
})

test_that("validate_datasets errors when country dataset missing required columns", {
  # Valid group datasets
  group_df <- tibble::tibble(
    group = "Africa",
    cpia_year = 2020,
    group_type = "Region",
    q12a = 3.4
  )
  
  # Country dataset missing 'economy' column
  bad_df <- tibble::tibble(
    cpia_year = 2020,
    region = "Africa",
    income_group = "Lower middle",
    q12a = 3.5
  )
  
  good_df <- tibble::tibble(
    economy = "Kenya",
    cpia_year = 2020,
    region = "Africa",
    income_group = "Lower middle",
    q12a = 3.5
  )
  
  expect_error(
    validate_datasets(bad_df, good_df, group_df, group_df),
    "standard_data is missing required columns: economy"
  )
})

test_that("validate_datasets errors when group dataset missing required columns", {
  # Valid country datasets
  country_df <- tibble::tibble(
    economy = "Kenya",
    cpia_year = 2020,
    region = "Africa",
    income_group = "Lower middle",
    q12a = 3.5
  )
  
  # Group dataset missing 'group_type' column
  bad_group_df <- tibble::tibble(
    group = "Africa",
    cpia_year = 2020,
    q12a = 3.4
  )
  
  good_group_df <- tibble::tibble(
    group = "Africa",
    cpia_year = 2020,
    group_type = "Region",
    q12a = 3.4
  )
  
  expect_error(
    validate_datasets(country_df, country_df, bad_group_df, good_group_df),
    "group_standard_data is missing required columns: group_type"
  )
})

test_that("validate_datasets errors when dataset has no question columns", {
  # Valid group dataset
  group_df <- tibble::tibble(
    group = "Africa",
    cpia_year = 2020,
    group_type = "Region",
    q12a = 3.4
  )
  
  # Country dataset with no question columns
  no_questions_df <- tibble::tibble(
    economy = "Kenya",
    cpia_year = 2020,
    region = "Africa",
    income_group = "Lower middle",
    other_col = 3.5
  )
  
  good_df <- tibble::tibble(
    economy = "Kenya",
    cpia_year = 2020,
    region = "Africa",
    income_group = "Lower middle",
    q12a = 3.5
  )
  
  expect_error(
    validate_datasets(no_questions_df, good_df, group_df, group_df),
    "standard_data has no question columns"
  )
})

test_that("validate_datasets handles empty data frames with correct structure", {
  # Empty data frames with correct columns should pass validation
  empty_country <- tibble::tibble(
    economy = character(),
    cpia_year = numeric(),
    region = character(),
    income_group = character(),
    q12a = numeric()
  )
  
  empty_group <- tibble::tibble(
    group = character(),
    cpia_year = numeric(),
    group_type = character(),
    q12a = numeric()
  )
  
  # Should not error - structure is valid even if empty
  expect_silent(
    validate_datasets(empty_country, empty_country, empty_group, empty_group)
  )
})

test_that("validate_datasets errors when multiple columns missing", {
  # Valid group datasets
  good_group <- tibble::tibble(
    group = "Africa",
    cpia_year = 2020,
    group_type = "Region",
    q12a = 3.4
  )
  
  # Country dataset missing both economy AND region
  bad_df <- tibble::tibble(
    cpia_year = 2020,
    income_group = "Lower middle",
    q12a = 3.5
  )
  
  good_df <- tibble::tibble(
    economy = "Kenya",
    cpia_year = 2020,
    region = "Africa",
    income_group = "Lower middle",
    q12a = 3.5
  )
  
  # Should error mentioning both missing columns
  expect_error(
    validate_datasets(bad_df, good_df, good_group, good_group),
    "economy.*region"
  )
})

test_that("validate_datasets accepts question columns without letter suffix", {
  # Test with q1, q2 (no letter suffix - valid per regex ^q\\d+[a-z]?$)
  country_df <- tibble::tibble(
    economy = "Kenya",
    cpia_year = 2020,
    region = "Africa",
    income_group = "Lower middle",
    q1 = 3.5,
    q2 = 3.6
  )
  
  group_df <- tibble::tibble(
    group = "Africa",
    cpia_year = 2020,
    group_type = "Region",
    q1 = 3.4,
    q2 = 3.5
  )
  
  # Should pass - [a-z]? means letter suffix is optional
  expect_silent(
    validate_datasets(country_df, country_df, group_df, group_df)
  )
})

