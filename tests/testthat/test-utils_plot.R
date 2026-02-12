test_that("add_plot_styling_columns adds required columns", {
  mock_data <- tibble::tibble(
    economy = c("Kenya", "Tanzania", "Kenya", "Tanzania"),
    year = c(2020, 2020, 2021, 2021),
    score = c(3.5, 3.2, 3.6, 3.3),
    display_name = c("Kenya", "Tanzania", "Kenya", "Tanzania"),
    line_type = c("solid", "dashed", "solid", "dashed")
  )
  
  result <- add_plot_styling_columns(mock_data, "Kenya")
  
  # Check new columns exist
  expect_true("line_size" %in% names(result))
  expect_true("year_factor" %in% names(result))
  
  # Check line_size values
  kenya_rows <- result[result$economy == "Kenya", ]
  expect_equal(unique(kenya_rows$line_size), 1.2)
  
  tanzania_rows <- result[result$economy == "Tanzania", ]
  expect_equal(unique(tanzania_rows$line_size), 0.8)
  
  # Check year_factor is a factor
  expect_s3_class(result$year_factor, "factor")
})

test_that("add_plot_styling_columns preserves original columns", {
  mock_data <- tibble::tibble(
    economy = c("Kenya", "Kenya"),
    year = c(2020, 2021),
    score = c(3.5, 3.6),
    display_name = c("Kenya", "Kenya"),
    line_type = c("solid", "solid")
  )
  
  result <- add_plot_styling_columns(mock_data, "Kenya")
  
  # Original columns should still exist
  expect_true(all(c("economy", "year", "score", "display_name", "line_type") %in% names(result)))
})

test_that("create_base_cpia_plot returns ggplot object", {
  mock_data <- tibble::tibble(
    year_factor = factor(c(2020, 2021)),
    score = c(3.5, 3.6),
    display_name = c("Kenya", "Kenya"),
    line_type = c("solid", "solid"),
    line_size = c(1.2, 1.2),
    year = c(2020, 2021)
  )
  
  plot <- create_base_cpia_plot(mock_data, "q12a")
  
  expect_s3_class(plot, "gg")
  expect_s3_class(plot, "ggplot")
})

test_that("style_cpia_plot adds labels and theme", {
  mock_data <- tibble::tibble(
    year_factor = factor(c(2020, 2021)),
    score = c(3.5, 3.6),
    display_name = c("Kenya", "Kenya"),
    line_type = c("solid", "solid"),
    line_size = c(1.2, 1.2),
    year = c(2020, 2021)
  )
  
  base_plot <- create_base_cpia_plot(mock_data, "q12a")
  styled_plot <- style_cpia_plot(base_plot, "q12a")
  
  expect_s3_class(styled_plot, "gg")
  
  # Check labels exist
  expect_true(!is.null(styled_plot$labels$title))
  expect_true(!is.null(styled_plot$labels$x))
  expect_true(!is.null(styled_plot$labels$y))
  
  # Check title contains question code
  expect_true(grepl("q12a", styled_plot$labels$title))
})

test_that("convert_to_plotly returns plotly object", {
  mock_data <- tibble::tibble(
    year_factor = factor(c(2020, 2021)),
    score = c(3.5, 3.6),
    display_name = c("Kenya", "Kenya"),
    line_type = c("solid", "solid"),
    line_size = c(1.2, 1.2),
    year = c(2020, 2021)
  )
  
  base_plot <- create_base_cpia_plot(mock_data, "q12a")
  styled_plot <- style_cpia_plot(base_plot, "q12a")
  plotly_obj <- convert_to_plotly(styled_plot)
  
  expect_s3_class(plotly_obj, "plotly")
})

test_that("create_cpia_plot orchestrates all plotting steps", {
  mock_data <- tibble::tibble(
    economy = c("Kenya", "Tanzania", "Kenya", "Tanzania"),
    year = c(2020, 2020, 2021, 2021),
    score = c(3.5, 3.2, 3.6, 3.3),
    display_name = c("Kenya", "Tanzania", "Kenya", "Tanzania"),
    line_type = c("solid", "dashed", "solid", "dashed")
  )
  
  result <- create_cpia_plot(mock_data, "Kenya", "q12a")
  
  # Should return a plotly object
  expect_s3_class(result, "plotly")
  
  # Check that plotly has data
  expect_true(!is.null(result$x))
})

test_that("create_cpia_plot handles single country", {
  mock_data <- tibble::tibble(
    economy = c("Kenya", "Kenya"),
    year = c(2020, 2021),
    score = c(3.5, 3.6),
    display_name = c("Kenya", "Kenya"),
    line_type = c("solid", "solid")
  )
  
  result <- create_cpia_plot(mock_data, "Kenya", "q12a")
  
  expect_s3_class(result, "plotly")
})

test_that("create_cpia_plot handles multiple comparators", {
  mock_data <- tibble::tibble(
    economy = c("Kenya", "Tanzania", "Uganda", "Kenya", "Tanzania", "Uganda"),
    year = c(2020, 2020, 2020, 2021, 2021, 2021),
    score = c(3.5, 3.2, 3.4, 3.6, 3.3, 3.5),
    display_name = c("Kenya", "Tanzania", "Uganda", "Kenya", "Tanzania", "Uganda"),
    line_type = c("solid", "dashed", "dashed", "solid", "dashed", "dashed")
  )
  
  result <- create_cpia_plot(mock_data, "Kenya", "q16a")
  
  expect_s3_class(result, "plotly")
})
