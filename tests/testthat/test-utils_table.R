test_that("prepare_table_data converts to wide format", {
  mock_data <- tibble::tibble(
    year = c(2020, 2020, 2021, 2021),
    display_name = c("Kenya", "Tanzania", "Kenya", "Tanzania"),
    score = c(3.5, 3.2, 3.6, 3.3)
  )
  
  result <- prepare_table_data(mock_data)
  
  expect_s3_class(result, "tbl_df")
  
  # Check structure
  expect_true("Year" %in% names(result))
  expect_true("Kenya" %in% names(result))
  expect_true("Tanzania" %in% names(result))
  
  # Check dimensions: 2 years (rows) x 3 columns (Year + 2 countries)
  expect_equal(nrow(result), 2)
  expect_equal(ncol(result), 3)
})

test_that("prepare_table_data arranges by year", {
  mock_data <- tibble::tibble(
    year = c(2021, 2020, 2021, 2020),
    display_name = c("Kenya", "Kenya", "Tanzania", "Tanzania"),
    score = c(3.6, 3.5, 3.3, 3.2)
  )
  
  result <- prepare_table_data(mock_data)
  
  # Years should be sorted
  expect_equal(result$Year, c(2020, 2021))
})

test_that("prepare_table_data handles single country", {
  mock_data <- tibble::tibble(
    year = c(2020, 2021, 2022),
    display_name = c("Kenya", "Kenya", "Kenya"),
    score = c(3.5, 3.6, 3.7)
  )
  
  result <- prepare_table_data(mock_data)
  
  expect_equal(nrow(result), 3)
  expect_equal(ncol(result), 2)  # Year + Kenya
  expect_equal(names(result), c("Year", "Kenya"))
})

test_that("prepare_table_data handles multiple comparators", {
  mock_data <- tibble::tibble(
    year = rep(2020:2021, each = 4),
    display_name = rep(c("Kenya", "Tanzania", "Africa", "Lower middle"), 2),
    score = c(3.5, 3.2, 3.4, 3.3, 3.6, 3.3, 3.5, 3.4)
  )
  
  result <- prepare_table_data(mock_data)
  
  expect_equal(nrow(result), 2)
  expect_equal(ncol(result), 5)  # Year + 4 entities
})

test_that("create_cpia_table returns DT datatable", {
  skip_if_not_installed("DT")
  
  # Use raw plot data format
  mock_plot_data <- tibble::tibble(
    year = c(2020, 2020, 2021, 2021),
    display_name = c("Kenya", "Tanzania", "Kenya", "Tanzania"),
    score = c(3.5, 3.2, 3.6, 3.3)
  )
  
  result <- create_cpia_table(mock_plot_data)
  
  expect_s3_class(result, "datatables")
})

test_that("create_cpia_table handles single column data", {
  skip_if_not_installed("DT")
  
  # Use raw plot data format
  mock_plot_data <- tibble::tibble(
    year = c(2020, 2021),
    display_name = c("Kenya", "Kenya"),
    score = c(3.5, 3.6)
  )
  
  result <- create_cpia_table(mock_plot_data)
  
  expect_s3_class(result, "datatables")
})

test_that("create_cpia_table configures export buttons", {
  skip_if_not_installed("DT")
  
  # Use raw plot data format
  mock_plot_data <- tibble::tibble(
    year = c(2020, 2020, 2021, 2021),
    display_name = c("Kenya", "Tanzania", "Kenya", "Tanzania"),
    score = c(3.5, 3.2, 3.6, 3.3)
  )
  
  result <- create_cpia_table(mock_plot_data)
  
  # Check options are set
  expect_true(!is.null(result$x$options))
  expect_equal(result$x$options$pageLength, 15)
  expect_true(result$x$options$scrollX)
})
