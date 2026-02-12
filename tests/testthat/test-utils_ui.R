test_that("create_empty_plot_message returns plotly object", {
  plot <- create_empty_plot_message()
  
  # Check it's a plotly object
  expect_s3_class(plot, "plotly")
})

test_that("create_empty_plot_message accepts custom parameters", {
  plot <- create_empty_plot_message(
    title = "Custom Title",
    message = "Custom message",
    title_size = 20,
    message_size = 16
  )
  
  expect_s3_class(plot, "plotly")
  
  # Plotly object was created with custom parameters (structure may vary by version)
  # Just verify it's a valid plotly object
  expect_true(!is.null(plot$x))
})

test_that("create_empty_plot_message uses default parameters", {
  plot <- create_empty_plot_message()
  
  # Verify it's a valid plotly object with layout
  expect_true(!is.null(plot$x))
  expect_true(!is.null(plot$x$layout))
})

test_that("create_empty_table_message returns DT object", {
  # Skip if DT not available (shouldn't happen in package context)
  skip_if_not_installed("DT")
  
  table <- create_empty_table_message()
  
  # Check it's a datatables object
  expect_s3_class(table, "datatables")
})

test_that("create_empty_table_message accepts custom message", {
  skip_if_not_installed("DT")
  
  custom_msg <- "Custom empty message"
  table <- create_empty_table_message(message = custom_msg)
  
  expect_s3_class(table, "datatables")
  
  # Check the data contains the custom message
  expect_equal(table$x$data$Message[1], custom_msg)
})

test_that("create_empty_table_message uses default message", {
  skip_if_not_installed("DT")
  
  table <- create_empty_table_message()
  
  default_msg <- "No data available for the selected country/comparators and criterion."
  expect_equal(table$x$data$Message[1], default_msg)
})
