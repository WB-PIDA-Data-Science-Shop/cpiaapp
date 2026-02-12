test_that("CPIA app launches without errors", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("cpiaetl")
  skip_on_ci()
  skip_on_cran()
  
  # Skip if Chrome/processx cannot be launched (e.g., blocked by group policy)
  tryCatch({
    chromote::ChromeSession$new()$close()
  }, error = function(e) {
    skip("Chrome cannot be launched (may be blocked by system policy)")
  })
  
  # Create a temporary app for testing
  app <- shinytest2::AppDriver$new(
    app_dir = system.file(package = "cpiaapp"),
    name = "cpia-app-launch",
    height = 800,
    width = 1200
  )
  
  # Check that app starts successfully
  expect_true(app$get_url() != "")
  
  # Stop the app
  app$stop()
})

test_that("CPIA app renders main UI components", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("cpiaetl")
  skip_on_ci()
  skip_on_cran()
  
  tryCatch({
    chromote::ChromeSession$new()$close()
  }, error = function(e) {
    skip("Chrome cannot be launched (may be blocked by system policy)")
  })
  
  app <- shinytest2::AppDriver$new(
    app_dir = system.file(package = "cpiaapp"),
    name = "cpia-app-ui",
    height = 800,
    width = 1200
  )
  
  # Wait for app to initialize
  Sys.sleep(2)
  
  # Check that key UI elements exist
  expect_true(app$get_value(input = "viz-country") != "")
  expect_true(app$get_value(input = "viz-question") != "")
  
  app$stop()
})

test_that("CPIA app plot renders with default selections", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("cpiaetl")
  skip_on_ci()
  skip_on_cran()
  
  tryCatch({
    chromote::ChromeSession$new()$close()
  }, error = function(e) {
    skip("Chrome cannot be launched (may be blocked by system policy)")
  })
  
  app <- shinytest2::AppDriver$new(
    app_dir = system.file(package = "cpiaapp"),
    name = "cpia-app-plot",
    height = 800,
    width = 1200
  )
  
  # Wait for plot to render
  Sys.sleep(3)
  
  # Check that plot output exists
  expect_true(app$get_value(output = "viz-score_plot") != "")
  
  app$stop()
})

test_that("CPIA app table renders with default selections", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("cpiaetl")
  skip_on_ci()
  skip_on_cran()
  
  tryCatch({
    chromote::ChromeSession$new()$close()
  }, error = function(e) {
    skip("Chrome cannot be launched (may be blocked by system policy)")
  })
  
  app <- shinytest2::AppDriver$new(
    app_dir = system.file(package = "cpiaapp"),
    name = "cpia-app-table",
    height = 800,
    width = 1200
  )
  
  # Wait for table to render
  Sys.sleep(3)
  
  # Check that table output exists
  table_output <- app$get_value(output = "viz-score_table")
  expect_true(!is.null(table_output))
  
  app$stop()
})

test_that("CPIA app responds to input changes", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("cpiaetl")
  skip_on_ci()
  skip_on_cran()
  
  tryCatch({
    chromote::ChromeSession$new()$close()
  }, error = function(e) {
    skip("Chrome cannot be launched (may be blocked by system policy)")
  })
  
  app <- shinytest2::AppDriver$new(
    app_dir = system.file(package = "cpiaapp"),
    name = "cpia-app-interaction",
    height = 800,
    width = 1200
  )
  
  # Wait for app to initialize
  Sys.sleep(2)
  
  # Get initial question selection
  initial_question <- app$get_value(input = "viz-question")
  
  # Change question selection (assuming q12b exists)
  app$set_inputs(`viz-question` = "q12b")
  Sys.sleep(2)
  
  # Verify the input changed
  new_question <- app$get_value(input = "viz-question")
  expect_equal(new_question, "q12b")
  expect_false(new_question == initial_question)
  
  # Check that plot still renders after input change
  expect_true(app$get_value(output = "viz-score_plot") != "")
  
  app$stop()
})

test_that("CPIA app switches between standard and africaii data", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("cpiaetl")
  skip_on_ci()
  skip_on_cran()
  
  tryCatch({
    chromote::ChromeSession$new()$close()
  }, error = function(e) {
    skip("Chrome cannot be launched (may be blocked by system policy)")
  })
  
  app <- shinytest2::AppDriver$new(
    app_dir = system.file(package = "cpiaapp"),
    name = "cpia-app-data-switch",
    height = 800,
    width = 1200
  )
  
  # Wait for app to initialize
  Sys.sleep(2)
  
  # Toggle africaii checkbox
  app$set_inputs(`viz-use_africaii` = TRUE)
  Sys.sleep(2)
  
  # Verify checkbox is checked
  expect_true(app$get_value(input = "viz-use_africaii"))
  
  # Check that outputs still render
  expect_true(app$get_value(output = "viz-score_plot") != "")
  
  app$stop()
})
