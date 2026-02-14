test_that("get_cpia_questions returns correct structure", {
  questions <- get_cpia_questions()
  
  # Check it returns a tibble (which is also a data.frame)
  expect_s3_class(questions, "tbl_df")
  expect_s3_class(questions, "data.frame")
  
  # Check required columns exist
  expect_true(all(c("question_code", "question_label", "category", "subcategory") %in% names(questions)))
  
  # Check we have 11 governance questions with available data (excludes q13a, q13c)
  expect_equal(nrow(questions), 11)
  
  # Check all are governance category
  expect_true(all(questions$category == "Governance"))
  
  # Check some expected question codes exist
  expect_true("q12a" %in% questions$question_code)
  expect_true("q13b" %in% questions$question_code)
  expect_true("q16d" %in% questions$question_code)
  
  # Check that questions without data are excluded
  expect_false("q13a" %in% questions$question_code)
  expect_false("q13c" %in% questions$question_code)
  
  # Check subcategories are properly extracted
  expect_true(all(questions$subcategory %in% c("Q12", "Q13", "Q15", "Q16")))
})

test_that("get_governance_questions filters correctly", {
  gov_questions <- get_governance_questions()
  
  # Should return all governance questions with available data (11 questions)
  all_questions <- get_cpia_questions()
  
  expect_equal(nrow(gov_questions), 11)
  expect_equal(nrow(gov_questions), nrow(all_questions))
  
  # All should be governance category
  expect_true(all(gov_questions$category == "Governance"))
  
  # Check expected governance question codes (excludes q13a and q13c which have no data)
  expected_codes <- c("q12a", "q12b", "q12c", "q13b", "q15a", "q15b", "q15c", "q16a", "q16b", "q16c", "q16d")
  expect_true(all(gov_questions$question_code %in% expected_codes))
  expect_equal(length(gov_questions$question_code), length(expected_codes))
})

test_that("format_question_choices creates named vector with codes", {
  questions <- get_governance_questions()
  choices <- format_question_choices(questions, include_question_code = TRUE)
  
  # Check it's a named character vector
  expect_type(choices, "character")
  expect_true(!is.null(names(choices)))
  
  # Check values are question codes
  expect_equal(as.character(choices), questions$question_code)
  
  # Check names include question codes (uppercase) - should match Q12, Q13, Q15, Q16
  expect_true(all(grepl("Q12|Q13|Q15|Q16", names(choices))))
  
  # Check names include labels
  expect_true(all(grepl("-", names(choices))))
})

test_that("format_question_choices creates named vector without codes", {
  questions <- get_governance_questions()
  choices <- format_question_choices(questions, include_question_code = FALSE)
  
  # Check it's a named character vector
  expect_type(choices, "character")
  expect_true(!is.null(names(choices)))
  
  # Check values are question codes
  expect_equal(as.character(choices), questions$question_code)
  
  # Check names are just labels (no Q12A prefix)
  expect_false(any(grepl("^Q[0-9]", names(choices))))
})

test_that("format_question_choices handles empty data frame", {
  empty_df <- tibble::tibble(
    question_code = character(0),
    question_label = character(0)
  )
  
  choices <- format_question_choices(empty_df)
  
  expect_length(choices, 0)
  expect_type(choices, "character")
})

test_that("format_question_choices errors on invalid input", {
  bad_df <- tibble::tibble(
    code = c("q12a", "q12b"),
    label = c("Label 1", "Label 2")
  )
  
  expect_error(
    format_question_choices(bad_df),
    "must contain 'question_code' and 'question_label' columns"
  )
})
