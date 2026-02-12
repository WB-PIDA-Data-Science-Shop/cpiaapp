test_that("prepare_country_data extracts selected country correctly", {
  # Create mock data
  mock_data <- tibble::tibble(
    economy = c("Kenya", "Kenya", "Tanzania", "Tanzania"),
    cpia_year = c(2020, 2021, 2020, 2021),
    q12a = c(3.5, 3.6, 3.2, 3.3),
    region = c("Africa", "Africa", "Africa", "Africa"),
    income_group = c("Lower middle", "Lower middle", "Lower middle", "Lower middle")
  )
  
  result <- prepare_country_data(mock_data, "Kenya", "q12a")
  
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_equal(unique(result$economy), "Kenya")
  expect_equal(result$score, c(3.5, 3.6))
  expect_equal(result$group_type, c("Selected Country", "Selected Country"))
  expect_equal(result$line_type, c("solid", "solid"))
})

test_that("prepare_country_data filters out NA scores", {
  mock_data <- tibble::tibble(
    economy = c("Kenya", "Kenya"),
    cpia_year = c(2020, 2021),
    q12a = c(3.5, NA),
    region = c("Africa", "Africa"),
    income_group = c("Lower middle", "Lower middle")
  )
  
  result <- prepare_country_data(mock_data, "Kenya", "q12a")
  
  expect_equal(nrow(result), 1)
  expect_equal(result$score, 3.5)
})

test_that("prepare_group_comparators handles regions correctly", {
  mock_group_data <- tibble::tibble(
    group = c("Africa", "Africa", "Asia", "Asia"),
    cpia_year = c(2020, 2021, 2020, 2021),
    q12a = c(3.5, 3.6, 4.0, 4.1)
  )
  
  result <- cpiaapp:::prepare_group_comparators(
    mock_group_data, 
    c("Africa", "Asia"), 
    "q12a", 
    "region"
  )
  
  expect_equal(nrow(result), 4)
  expect_equal(unique(result$comparator_category), "region")
  expect_equal(result$line_type, rep("dashed", 4))
  expect_true(all(result$display_name %in% c("Africa", "Asia")))
  expect_true(all(!is.na(result$region)))
  expect_true(all(is.na(result$income_group)))
})

test_that("prepare_group_comparators handles income groups correctly", {
  mock_group_data <- tibble::tibble(
    group = c("Low income", "Low income", "High income", "High income"),
    cpia_year = c(2020, 2021, 2020, 2021),
    q12a = c(3.0, 3.1, 5.0, 5.1)
  )
  
  result <- cpiaapp:::prepare_group_comparators(
    mock_group_data,
    c("Low income", "High income"),
    "q12a",
    "income_group"
  )
  
  expect_equal(nrow(result), 4)
  expect_equal(unique(result$comparator_category), "income_group")
  expect_true(all(!is.na(result$income_group)))
  expect_true(all(is.na(result$region)))
})

test_that("prepare_group_comparators returns empty tibble when no groups selected", {
  mock_group_data <- tibble::tibble(
    group = c("Africa", "Asia"),
    cpia_year = c(2020, 2020),
    q12a = c(3.5, 4.0)
  )
  
  result <- cpiaapp:::prepare_group_comparators(mock_group_data, NULL, "q12a", "region")
  
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  
  result2 <- cpiaapp:::prepare_group_comparators(mock_group_data, character(0), "q12a", "region")
  expect_equal(nrow(result2), 0)
})

test_that("prepare_region_comparators returns empty tibble when no regions selected", {
  mock_group_data <- tibble::tibble(
    group = c("Africa", "Asia"),
    cpia_year = c(2020, 2020),
    q12a = c(3.5, 4.0)
  )
  
  result <- prepare_region_comparators(mock_group_data, NULL, "q12a")
  
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  
  result2 <- prepare_region_comparators(mock_group_data, character(0), "q12a")
  expect_equal(nrow(result2), 0)
})

test_that("prepare_region_comparators extracts selected regions correctly", {
  mock_group_data <- tibble::tibble(
    group = c("Africa", "Africa", "Asia", "Asia"),
    cpia_year = c(2020, 2021, 2020, 2021),
    q12a = c(3.5, 3.6, 4.0, 4.1)
  )
  
  result <- prepare_region_comparators(mock_group_data, c("Africa", "Asia"), "q12a")
  
  expect_equal(nrow(result), 4)
  expect_equal(unique(result$comparator_category), "region")
  expect_equal(result$line_type, rep("dashed", 4))
  expect_true(all(result$display_name %in% c("Africa", "Asia")))
})

test_that("prepare_income_comparators returns empty tibble when no income groups selected", {
  mock_group_data <- tibble::tibble(
    group = c("Low income", "High income"),
    cpia_year = c(2020, 2020),
    q12a = c(3.0, 5.0)
  )
  
  result <- prepare_income_comparators(mock_group_data, NULL, "q12a")
  
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

test_that("prepare_income_comparators extracts selected income groups correctly", {
  mock_group_data <- tibble::tibble(
    group = c("Low income", "Low income", "High income", "High income"),
    cpia_year = c(2020, 2021, 2020, 2021),
    q12a = c(3.0, 3.1, 5.0, 5.1)
  )
  
  result <- prepare_income_comparators(mock_group_data, "Low income", "q12a")
  
  expect_equal(nrow(result), 2)
  expect_equal(unique(result$comparator_category), "income_group")
  expect_equal(result$display_name, c("Low income", "Low income"))
})

test_that("prepare_country_comparators returns empty tibble when no countries selected", {
  mock_data <- tibble::tibble(
    economy = c("Kenya", "Tanzania"),
    cpia_year = c(2020, 2020),
    q12a = c(3.5, 3.2),
    region = c("Africa", "Africa"),
    income_group = c("Lower middle", "Lower middle")
  )
  
  result <- prepare_country_comparators(mock_data, NULL, "q12a")
  
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

test_that("prepare_country_comparators extracts custom countries correctly", {
  mock_data <- tibble::tibble(
    economy = c("Kenya", "Kenya", "Tanzania", "Tanzania"),
    cpia_year = c(2020, 2021, 2020, 2021),
    q12a = c(3.5, 3.6, 3.2, 3.3),
    region = c("Africa", "Africa", "Africa", "Africa"),
    income_group = c("Lower middle", "Lower middle", "Lower middle", "Lower middle")
  )
  
  result <- prepare_country_comparators(mock_data, c("Kenya", "Tanzania"), "q12a")
  
  expect_equal(nrow(result), 4)
  expect_equal(unique(result$comparator_category), "country")
  expect_equal(result$line_type, rep("dashed", 4))
})

test_that("prepare_plot_data combines all data sources correctly", {
  mock_data <- tibble::tibble(
    economy = c("Kenya", "Kenya", "Tanzania", "Tanzania"),
    cpia_year = c(2020, 2021, 2020, 2021),
    q12a = c(3.5, 3.6, 3.2, 3.3),
    region = c("Africa", "Africa", "Africa", "Africa"),
    income_group = c("Lower middle", "Lower middle", "Lower middle", "Lower middle")
  )
  
  mock_group_data <- tibble::tibble(
    group = c("Africa", "Africa", "Lower middle", "Lower middle"),
    cpia_year = c(2020, 2021, 2020, 2021),
    q12a = c(3.4, 3.5, 3.3, 3.4)
  )
  
  result <- prepare_plot_data(
    data = mock_data,
    group_data = mock_group_data,
    selected_country = "Kenya",
    question = "q12a",
    selected_regions = "Africa",
    selected_income_groups = "Lower middle",
    custom_countries = "Tanzania"
  )
  
  # Should have: Kenya (2 rows) + Africa region (2 rows) + 
  #              Lower middle income (2 rows) + Tanzania (2 rows) = 8 rows
  expect_equal(nrow(result), 8)
  
  # Check we have all types
  expect_true("Selected Country" %in% result$group_type)
  expect_true("Comparator" %in% result$group_type)
  
  # Check selected country has solid line
  kenya_rows <- result[result$economy == "Kenya", ]
  expect_equal(unique(kenya_rows$line_type), "solid")
  
  # Check comparators have dashed lines
  comparator_rows <- result[result$group_type == "Comparator", ]
  expect_equal(unique(comparator_rows$line_type), "dashed")
})

test_that("prepare_plot_data works with only country data (no comparators)", {
  mock_data <- tibble::tibble(
    economy = c("Kenya", "Kenya"),
    cpia_year = c(2020, 2021),
    q12a = c(3.5, 3.6),
    region = c("Africa", "Africa"),
    income_group = c("Lower middle", "Lower middle")
  )
  
  mock_group_data <- tibble::tibble(
    group = character(),
    cpia_year = numeric(),
    q12a = numeric()
  )
  
  result <- prepare_plot_data(
    data = mock_data,
    group_data = mock_group_data,
    selected_country = "Kenya",
    question = "q12a"
  )
  
  expect_equal(nrow(result), 2)
  expect_equal(unique(result$group_type), "Selected Country")
})

test_that("prepare_country_data errors when question not found in data", {
  mock_data <- tibble::tibble(
    economy = c("Kenya", "Kenya"),
    cpia_year = c(2020, 2021),
    q12a = c(3.5, 3.6),
    region = c("Africa", "Africa"),
    income_group = c("Lower middle", "Lower middle")
  )
  
  expect_error(
    prepare_country_data(mock_data, "Kenya", "q99z"),
    "Question 'q99z' not found in data"
  )
})

test_that("prepare_group_comparators errors when question not found in group data", {
  mock_group_data <- tibble::tibble(
    group = c("Africa", "Asia"),
    cpia_year = c(2020, 2020),
    q12a = c(3.5, 4.0)
  )
  
  expect_error(
    cpiaapp:::prepare_group_comparators(mock_group_data, "Africa", "q99z", "region"),
    "Question 'q99z' not found in group data"
  )
})

test_that("prepare_country_comparators errors when question not found in data", {
  mock_data <- tibble::tibble(
    economy = c("Kenya", "Tanzania"),
    cpia_year = c(2020, 2020),
    q12a = c(3.5, 3.2),
    region = c("Africa", "Africa"),
    income_group = c("Lower middle", "Lower middle")
  )
  
  expect_error(
    prepare_country_comparators(mock_data, "Kenya", "q99z"),
    "Question 'q99z' not found in data"
  )
})

