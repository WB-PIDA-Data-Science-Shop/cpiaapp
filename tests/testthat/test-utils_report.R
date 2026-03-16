# test-utils_report.R — Tests for prompt construction and Word document export
#
# Tests cover: load_prompt_file(), build_trend_text(), build_cpia_prompt(),
#              format_report_docx()
#
# All tests use self-contained mock data. No LLM calls are made.


# ── Helpers ────────────────────────────────────────────────────────────────────

# Minimal plot_data tibble with the same structure as prepare_plot_data() output
make_mock_plot_data <- function() {
  tibble::tibble(
    economy      = c("Kenya", "Kenya", "Kenya", "Africa (AFR)", "Low income"),
    year         = c(2021L, 2022L, 2023L, 2023L, 2023L),
    score        = c(3.0, 3.5, 3.5, 3.2, 2.9),
    display_name = c("Kenya", "Kenya", "Kenya", "Africa (AFR)", "Low income"),
    group_type   = c(
      "Selected Country", "Selected Country", "Selected Country",
      "Comparator", "Comparator"
    )
  )
}


# ── load_prompt_file() ─────────────────────────────────────────────────────────

test_that("load_prompt_file loads cpia_report_prompt.md", {
  text <- load_prompt_file("cpia_report_prompt.md")

  expect_type(text, "character")
  expect_length(text, 1L)
  expect_gt(nchar(text), 100L)
  # Check it contains key phrases from the system prompt
  expect_true(grepl("CPIA", text, fixed = TRUE))
  expect_true(grepl("1.*6|1-6|1 to 6|1\u20136", text))
})

test_that("load_prompt_file loads cpia_style_examples.md", {
  text <- load_prompt_file("cpia_style_examples.md")

  expect_type(text, "character")
  expect_length(text, 1L)
  expect_gt(nchar(text), 100L)
  expect_true(grepl("Benin|Cote|score", text, ignore.case = TRUE))
})

test_that("load_prompt_file errors for missing file", {
  expect_error(
    load_prompt_file("this_file_does_not_exist.md"),
    "not found in inst/prompts/"
  )
})


# ── build_trend_text() ─────────────────────────────────────────────────────────

test_that("build_trend_text handles empty data frame", {
  empty <- tibble::tibble(year = integer(0), score = numeric(0))
  result <- cpiaapp:::build_trend_text(empty, "Kenya")

  expect_type(result, "character")
  expect_length(result, 1L)
  expect_true(grepl("No historical", result))
})

test_that("build_trend_text handles single data point", {
  single <- tibble::tibble(year = 2023L, score = 3.5)
  result <- cpiaapp:::build_trend_text(single, "Kenya")

  expect_true(grepl("one data point", result, ignore.case = TRUE))
  expect_true(grepl("3.5", result))
  expect_true(grepl("2023", result))
})

test_that("build_trend_text correctly reports an increase", {
  scores <- tibble::tibble(year = c(2020L, 2023L), score = c(3.0, 3.5))
  result <- cpiaapp:::build_trend_text(scores, "Kenya")

  expect_true(grepl("increased", result, ignore.case = TRUE))
  expect_true(grepl("3.0", result))
  expect_true(grepl("3.5", result))
  expect_true(grepl("2020", result))
  expect_true(grepl("2023", result))
})

test_that("build_trend_text correctly reports a decrease", {
  scores <- tibble::tibble(year = c(2020L, 2023L), score = c(4.0, 3.0))
  result <- cpiaapp:::build_trend_text(scores, "Kenya")

  expect_true(grepl("decreased", result, ignore.case = TRUE))
  expect_true(grepl("4.0", result))
  expect_true(grepl("3.0", result))
})

test_that("build_trend_text correctly reports no change", {
  scores <- tibble::tibble(year = c(2020L, 2023L), score = c(3.5, 3.5))
  result <- cpiaapp:::build_trend_text(scores, "Kenya")

  expect_true(grepl("unchanged", result, ignore.case = TRUE))
  expect_true(grepl("3.5", result))
})


# ── build_cpia_prompt() ────────────────────────────────────────────────────────

test_that("build_cpia_prompt returns a named list with system and user", {
  prompt <- build_cpia_prompt(
    country        = "Kenya",
    question       = "q12a",
    question_label = "Property Rights and Rule-based Governance",
    plot_data      = make_mock_plot_data()
  )

  expect_type(prompt, "list")
  expect_named(prompt, c("system", "user"))
  expect_type(prompt$system, "character")
  expect_type(prompt$user,   "character")
  expect_length(prompt$system, 1L)
  expect_length(prompt$user,   1L)
})

test_that("build_cpia_prompt embeds country in user message", {
  prompt <- build_cpia_prompt(
    country        = "Kenya",
    question       = "q12a",
    question_label = "Property Rights and Rule-based Governance",
    plot_data      = make_mock_plot_data()
  )

  expect_true(grepl("Kenya", prompt$user, fixed = TRUE))
})

test_that("build_cpia_prompt embeds question code in user message", {
  prompt <- build_cpia_prompt(
    country        = "Kenya",
    question       = "q12a",
    question_label = "Property Rights and Rule-based Governance",
    plot_data      = make_mock_plot_data()
  )

  expect_true(grepl("q12a", prompt$user, fixed = TRUE))
})

test_that("build_cpia_prompt embeds score history in user message", {
  prompt <- build_cpia_prompt(
    country        = "Kenya",
    question       = "q12a",
    question_label = "Property Rights and Rule-based Governance",
    plot_data      = make_mock_plot_data()
  )

  # Should contain the year-score pairs from mock data
  expect_true(grepl("2021", prompt$user, fixed = TRUE))
  expect_true(grepl("2023", prompt$user, fixed = TRUE))
  expect_true(grepl("3.0", prompt$user,  fixed = TRUE))
})

test_that("build_cpia_prompt embeds comparator names in user message", {
  prompt <- build_cpia_prompt(
    country        = "Kenya",
    question       = "q12a",
    question_label = "Property Rights and Rule-based Governance",
    plot_data      = make_mock_plot_data()
  )

  expect_true(grepl("Africa", prompt$user, fixed = TRUE))
  expect_true(grepl("Low income", prompt$user, fixed = TRUE))
})

test_that("build_cpia_prompt handles plot_data with no comparators", {
  country_only <- tibble::tibble(
    economy      = c("Kenya", "Kenya"),
    year         = c(2022L, 2023L),
    score        = c(3.0, 3.5),
    display_name = c("Kenya", "Kenya"),
    group_type   = c("Selected Country", "Selected Country")
  )

  prompt <- build_cpia_prompt(
    country        = "Kenya",
    question       = "q12b",
    question_label = "Quality of Budgetary and Financial Management",
    plot_data      = country_only
  )

  expect_true(grepl("No comparators", prompt$user, fixed = TRUE))
})

test_that("build_cpia_prompt system text contains style examples", {
  prompt <- build_cpia_prompt(
    country        = "Kenya",
    question       = "q12a",
    question_label = "Property Rights and Rule-based Governance",
    plot_data      = make_mock_plot_data()
  )

  # Style examples are appended to system prompt
  expect_true(grepl("Style", prompt$system, ignore.case = TRUE))
})

test_that("build_cpia_prompt handles zero-row plot_data gracefully", {
  empty_data <- tibble::tibble(
    economy      = character(0),
    year         = integer(0),
    score        = numeric(0),
    display_name = character(0),
    group_type   = character(0)
  )

  # Should not error — returns prompt with "No data" messaging
  prompt <- build_cpia_prompt(
    country        = "Kenya",
    question       = "q12a",
    question_label = "Property Rights and Rule-based Governance",
    plot_data      = empty_data
  )

  expect_type(prompt, "list")
  expect_named(prompt, c("system", "user"))
  expect_true(grepl("No data", prompt$user, fixed = TRUE))
})


# ── format_report_docx() ──────────────────────────────────────────────────────

test_that("format_report_docx returns an rdocx object", {
  doc <- format_report_docx(
    report_text    = "Score Interpretation\n\nKenya's score was 3.5 in 2023.\n\nTrend Analysis\n\nThe score increased.",
    country        = "Kenya",
    question_label = "Property Rights and Rule-based Governance",
    question       = "q12a"
  )

  expect_s3_class(doc, "rdocx")
})

test_that("format_report_docx can be written to a temp file without error", {
  doc <- format_report_docx(
    report_text    = "Score Interpretation\n\nKenyas score was 3.5 in 2023.",
    country        = "Kenya",
    question_label = "Property Rights and Rule-based Governance",
    question       = "q12a"
  )

  tmp <- tempfile(fileext = ".docx")
  expect_no_error(print(doc, target = tmp))
  expect_true(file.exists(tmp))

  # Clean up
  unlink(tmp)
})

test_that("format_report_docx handles multi-paragraph report text", {
  report <- paste(
    "Score Interpretation",
    "",
    "Kenya scored 3.5 in 2023.",
    "",
    "Trend Analysis",
    "",
    "The score increased from 3.0 in 2021.",
    sep = "\n"
  )

  doc <- format_report_docx(
    report_text    = report,
    country        = "Kenya",
    question_label = "Property Rights and Rule-based Governance",
    question       = "q12a"
  )

  expect_s3_class(doc, "rdocx")
})

test_that("format_report_docx handles empty report text without error", {
  expect_no_error(
    format_report_docx(
      report_text    = "",
      country        = "Kenya",
      question_label = "Property Rights and Rule-based Governance",
      question       = "q12a"
    )
  )
})
