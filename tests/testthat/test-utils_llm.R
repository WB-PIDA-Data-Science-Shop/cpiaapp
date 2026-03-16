# test-utils_llm.R — Tests for LLM utility functions
#
# Tests cover: check_llm_available()
#
# stream_llm_response() requires a live LLM endpoint and is not unit-testable
# without a mock server. It is covered by integration tests (skipped in CI).
#
# check_llm_available() is tested by temporarily overriding the CPIA_LLM_BASE_URL
# environment variable to point at a known-unreachable address.


# ── check_llm_available() ──────────────────────────────────────────────────────

test_that("check_llm_available returns FALSE for unreachable endpoint", {
  withr::with_envvar(
    c(CPIA_LLM_BASE_URL = "http://localhost:19999"),
    expect_false(check_llm_available())
  )
})

test_that("check_llm_available returns a logical scalar", {
  withr::with_envvar(
    c(CPIA_LLM_BASE_URL = "http://localhost:19999"),
    {
      result <- check_llm_available()
      expect_type(result, "logical")
      expect_length(result, 1L)
    }
  )
})

test_that("check_llm_available reads CPIA_LLM_BASE_URL from environment", {
  # With no server on port 19998 this should always be FALSE
  withr::with_envvar(
    c(CPIA_LLM_BASE_URL = "http://127.0.0.1:19998"),
    expect_false(check_llm_available())
  )
})

test_that("check_llm_available falls back to default URL when env var unset", {
  # Temporarily unset the variable; function should still return a logical
  withr::with_envvar(
    c(CPIA_LLM_BASE_URL = NA),
    {
      result <- check_llm_available()
      expect_type(result, "logical")
      expect_length(result, 1L)
    }
  )
})

# ── stream_llm_response() — integration test (skipped) ────────────────────────

test_that("stream_llm_response is skipped without a live LLM endpoint", {
  # This is an end-to-end integration test that requires a running LLM.
  # It is always skipped in automated test runs. To run manually:
  #   1. Start Ollama: `ollama serve`
  #   2. Pull a model: `ollama pull llama3.2`
  #   3. Set CPIA_RUN_LLM_TESTS=true in .Renviron
  #   4. Re-run testthat
  skip_if_not(
    identical(Sys.getenv("CPIA_RUN_LLM_TESTS"), "true"),
    "Set CPIA_RUN_LLM_TESTS=true to run LLM integration tests"
  )

  mock_data <- tibble::tibble(
    economy      = c("Kenya", "Kenya"),
    year         = c(2022L, 2023L),
    score        = c(3.0, 3.5),
    display_name = c("Kenya", "Kenya"),
    group_type   = c("Selected Country", "Selected Country")
  )

  prompt <- build_cpia_prompt(
    country        = "Kenya",
    question       = "q12a",
    question_label = "Property Rights and Rule-based Governance",
    plot_data      = mock_data
  )

  received <- shiny::reactiveVal("")

  result <- stream_llm_response(
    prompt       = prompt,
    reactive_val = received,
    on_complete  = NULL
  )

  expect_type(result, "character")
  expect_gt(nchar(result), 0L)
})
