# Development Workflow

Step-by-step guides for common development tasks in the cpiaapp package.

## Quick Reference

- [Adding a New Comparator Type](#adding-a-new-comparator-type)
- [Modifying Plot Appearance](#modifying-plot-appearance)
- [Adding New Validation Rules](#adding-new-validation-rules)
- [Adding a New Question](#adding-a-new-question)
- [Updating Dependencies](#updating-dependencies)
- [Code Style Guidelines](#code-style-guidelines)
- [Git Workflow](#git-workflow)
- [Release Process](#release-process)

---

## Adding a New Comparator Type

**Scenario:** Add ability to compare by "Fragile State" status.

### Step 1: Add Preparation Function

Create new function in `R/utils_data_prep.R`:

```r
#' Prepare Fragile State Comparators
#'
#' Prepares fragile state average data for comparison plots.
#'
#' @param group_data Group aggregate dataset
#' @param selected_fragile_states Character vector of fragile state categories
#' @param question Question column name (e.g., "q12a")
#'
#' @return Tibble with fragile state averages, or empty tibble if no selection
#'
#' @keywords internal
prepare_fragile_state_comparators <- function(group_data, selected_fragile_states, question) {
  # Use existing internal helper
  prepare_group_comparators(
    group_data = group_data,
    groups = selected_fragile_states,
    question = question,
    category_type = "fragile_state"
  )
}
```

### Step 2: Update prepare_plot_data()

Add fragile state parameter and call new function:

```r
prepare_plot_data <- function(data, group_data, selected_country, question,
                              selected_regions = NULL,
                              selected_income_groups = NULL,
                              custom_countries = NULL,
                              selected_fragile_states = NULL) {  # New parameter
  
  # Existing preparation calls...
  country_data <- prepare_country_data(data, selected_country, question)
  region_data <- prepare_region_comparators(group_data, selected_regions, question)
  income_data <- prepare_income_comparators(group_data, selected_income_groups, question)
  country_comp_data <- prepare_country_comparators(data, custom_countries, question)
  
  # New fragile state preparation
  fragile_state_data <- prepare_fragile_state_comparators(
    group_data, selected_fragile_states, question
  )
  
  # Combine all data
  dplyr::bind_rows(
    country_data,
    region_data,
    income_data,
    country_comp_data,
    fragile_state_data  # Add to combination
  ) |>
    dplyr::arrange(economy, year)
}
```

### Step 3: Update UI (viz_ui.R)

Add fragile state selector:

```r
# In viz_ui sidebar
selectInput(
  inputId = "fragile_states",
  label = "Fragile State Status:",
  choices = c("Fragile", "Non-Fragile", "High Alert"),
  selected = NULL,
  multiple = TRUE
)
```

### Step 4: Update Server (viz_server.R)

Pass fragile state selection to prepare_plot_data():

```r
# In viz_server
plot_data <- prepare_plot_data(
  data = current_data(),
  group_data = current_group_data(),
  selected_country = input$country,
  question = input$question,
  selected_regions = input$regions,
  selected_income_groups = input$income_groups,
  custom_countries = input$custom_countries,
  selected_fragile_states = input$fragile_states  # New parameter
)
```

### Step 5: Write Tests

Add tests in `tests/testthat/test-utils_data_prep.R`:

```r
test_that("prepare_fragile_state_comparators returns empty for NULL", {
  result <- prepare_fragile_state_comparators(group_data, NULL, "q12a")
  expect_equal(nrow(result), 0)
  expect_s3_class(result, "tbl_df")
})

test_that("prepare_fragile_state_comparators processes fragile states", {
  result <- prepare_fragile_state_comparators(
    group_data, c("Fragile", "High Alert"), "q12a"
  )
  expect_gt(nrow(result), 0)
  expect_equal(unique(result$line_type), "dashed")
  expect_equal(unique(result$comparator_category), "fragile_state")
})

test_that("prepare_fragile_state_comparators errors with invalid question", {
  expect_error(
    prepare_fragile_state_comparators(group_data, "Fragile", "q99z"),
    "Question 'q99z' not found"
  )
})

# Add integration test for prepare_plot_data
test_that("prepare_plot_data includes fragile state comparators", {
  result <- prepare_plot_data(
    data, group_data, "Kenya", "q12a",
    selected_fragile_states = "Fragile"
  )
  expect_true("fragile_state" %in% result$comparator_category)
})
```

### Step 6: Document and Test

```r
# Update documentation
devtools::document()

# Run tests
devtools::test()  # Should pass

# Check package
devtools::check()  # Should be clean
```

---

## Modifying Plot Appearance

### Change Colors

Edit `create_plot_styling()` in `R/utils_plot.R`:

```r
create_plot_styling <- function(data) {
  # Current: Uses default color palette
  # colors <- scales::hue_pal()(n_items)
  
  # New: Custom color palette
  custom_colors <- c(
    "#1f77b4",  # Blue (selected country)
    "#ff7f0e",  # Orange
    "#2ca02c",  # Green
    "#d62728",  # Red
    "#9467bd",  # Purple
    "#8c564b",  # Brown
    "#e377c2"   # Pink
  )
  
  n_items <- length(unique(data$display_name))
  colors <- rep_len(custom_colors, n_items)  # Repeat if needed
  
  # Rest of function unchanged...
}
```

### Change Legend Position

Edit `create_base_plot()` in `R/utils_plot.R`:

```r
create_base_plot <- function(data, styling, question_label) {
  # ... existing code ...
  
  # Change legend position from bottom to right
  theme(
    legend.position = "right",      # Was "bottom"
    legend.direction = "vertical",  # Was "horizontal"
    legend.text = element_text(size = 11)
  )
}
```

### Change Plot Type (Line to Column)

Edit `create_base_plot()` in `R/utils_plot.R`:

```r
create_base_plot <- function(data, styling, question_label) {
  ggplot(data, aes(x = year, y = score, fill = display_name)) +
    geom_col(position = "dodge") +  # Was: geom_line() + geom_point()
    scale_fill_manual(
      values = styling$color_mapping,
      name = "Economy/Group",
      breaks = styling$legend_order
    ) +
    labs(
      title = question_label,
      x = "Year",
      y = "Score"
    ) +
    theme(
      legend.position = "bottom",
      legend.direction = "horizontal",
      legend.text = element_text(size = 11)
    )
}
```

### Add Smoothing Trend Line

Edit `create_base_plot()` in `R/utils_plot.R`:

```r
create_base_plot <- function(data, styling, question_label) {
  ggplot(data, aes(x = year, y = score, color = display_name, linetype = line_type)) +
    geom_line(linewidth = 1) +
    geom_point(size = 2) +
    geom_smooth(method = "lm", se = FALSE, linetype = "dotted", alpha = 0.5) +  # New
    # ... rest of function
}
```

---

## Adding New Validation Rules

### Scenario: Validate score ranges (1.0 - 6.0)

### Step 1: Add Validation Function

In `R/utils_data.R`:

```r
#' Validate Score Ranges
#'
#' Checks that all question scores are within valid CPIA range (1.0 - 6.0).
#'
#' @param data CPIA dataset with question columns
#'
#' @return TRUE invisibly if valid, throws error otherwise
#'
#' @keywords internal
validate_score_ranges <- function(data) {
  question_cols <- grep("^q\\d+[a-z]?$", names(data), value = TRUE)
  
  for (col in question_cols) {
    scores <- data[[col]][!is.na(data[[col]])]
    
    if (length(scores) > 0) {
      if (any(scores < 1.0 | scores > 6.0)) {
        invalid_scores <- scores[scores < 1.0 | scores > 6.0]
        stop(sprintf(
          "Invalid scores in column '%s': %s\nScores must be between 1.0 and 6.0",
          col,
          paste(head(invalid_scores, 5), collapse = ", ")
        ), call. = FALSE)
      }
    }
  }
  
  invisible(TRUE)
}
```

### Step 2: Call from validate_datasets()

```r
validate_datasets <- function(standard_data, africaii_data, 
                              group_standard_data, group_africaii_data) {
  # Existing validations...
  
  # Add score range validation
  validate_score_ranges(standard_data)
  validate_score_ranges(africaii_data)
  validate_score_ranges(group_standard_data)
  validate_score_ranges(group_africaii_data)
  
  invisible(TRUE)
}
```

### Step 3: Write Tests

In `tests/testthat/test-utils_data.R`:

```r
test_that("validate_score_ranges accepts valid scores", {
  valid_data <- tibble(
    economy = "Kenya",
    q12a = c(3.5, 4.0, 2.5),  # All within 1.0-6.0
    q12b = c(5.5, 6.0, 1.0)
  )
  
  expect_silent(validate_score_ranges(valid_data))
})

test_that("validate_score_ranges errors on scores > 6.0", {
  invalid_data <- tibble(
    economy = "Kenya",
    q12a = c(3.5, 7.0, 2.5)  # 7.0 is invalid
  )
  
  expect_error(
    validate_score_ranges(invalid_data),
    "Invalid scores in column 'q12a': 7"
  )
})

test_that("validate_score_ranges errors on scores < 1.0", {
  invalid_data <- tibble(
    economy = "Kenya",
    q12a = c(3.5, 0.5, 2.5)  # 0.5 is invalid
  )
  
  expect_error(
    validate_score_ranges(invalid_data),
    "Invalid scores in column 'q12a': 0.5"
  )
})

test_that("validate_score_ranges handles NA values", {
  data_with_na <- tibble(
    economy = "Kenya",
    q12a = c(3.5, NA, 2.5)  # NA should be ignored
  )
  
  expect_silent(validate_score_ranges(data_with_na))
})
```

---

## Adding a New Question

**Scenario:** cpiaetl adds q17a to the dataset.

### Good News: No Code Changes Needed!

The app **automatically detects new questions** because:

1. `get_cpia_questions()` dynamically reads from cpiaetl
2. `validate_datasets()` uses regex pattern `^q\d+[a-z]?$` (matches q17a)
3. UI dropdown populated from `format_question_choices()`

### Verify It Works

```r
# 1. Update cpiaetl package with new question
# (assumes cpiaetl maintainers added q17a)

# 2. Test locally
devtools::load_all()
run_cpiaapp()

# 3. Check dropdown includes q17a
questions <- get_cpia_questions()
"q17a" %in% questions$question_id  # Should be TRUE

# 4. Run tests
devtools::test()  # Should all pass

# 5. Deploy update
rsconnect::deployApp(forceUpdate = TRUE)
```

---

## Updating Dependencies

### Update Single Package

```r
# Update plotly to latest version
install.packages("plotly")

# Test app still works
devtools::test()
devtools::check()

# Update DESCRIPTION if needed
# Imports: plotly (>= 4.13.0)  # Was 4.12.0
```

### Update All Dependencies

```r
# Update all packages
update.packages(ask = FALSE)

# Test
devtools::test()

# If tests fail, investigate which package broke compatibility
```

### Add New Dependency

```r
# 1. Install package
install.packages("newpackage")

# 2. Add to DESCRIPTION
# In Imports section:
#   newpackage,

# 3. Use in code with @importFrom
#' @importFrom newpackage function_name

# 4. Document
devtools::document()

# 5. Check
devtools::check()
```

---

## Code Style Guidelines

### R Code Style

Follow tidyverse style guide with these specifics:

**Naming:**
```r
# Functions: snake_case
prepare_country_data()

# Variables: snake_case
selected_country <- "Kenya"

# Constants: SCREAMING_SNAKE_CASE
MAX_SCORE <- 6.0
```

**Pipes:**
```r
# Use native pipe |> (requires R >= 4.1.0)
data |>
  filter(economy == "Kenya") |>
  select(year, score)

# Not magrittr pipe %>%
```

**Spacing:**
```r
# Space after comma, around operators
result <- my_function(x, y, z)
if (x > 10) {

# Not: result<-my_function(x,y,z)
```

**Line Length:**
```r
# Keep under 90 characters for readability
# Break long function calls:
prepare_plot_data(
  data = standard_data,
  group_data = group_standard_data,
  selected_country = "Kenya"
)
```

### Documentation Style

**roxygen2 headers:**
```r
#' Function Name in Title Case
#'
#' Brief description of what function does. Should be one sentence.
#' Can add more detail in subsequent paragraphs if needed.
#'
#' @param data Description of data parameter
#' @param question Description of question parameter
#'
#' @return Description of return value with type (tibble, ggplot, etc.)
#'
#' @examples
#' \dontrun{
#' result <- my_function(data, "q12a")
#' }
#'
#' @importFrom dplyr filter select mutate
#' @keywords internal
```

### Test Style

**Test names:**
```r
# Use descriptive names with "function does X when Y" pattern
test_that("prepare_country_data returns empty tibble for NULL country", {
  # Test code
})

# Not: test_that("test1", {
```

**Arrange-Act-Assert:**
```r
test_that("function does X", {
  # Arrange: Set up test data
  data <- create_test_data()
  
  # Act: Call function
  result <- my_function(data)
  
  # Assert: Check expectations
  expect_equal(nrow(result), 10)
})
```

---

## Git Workflow

### Branch Strategy

```bash
# Main branch: production-ready code
git checkout main

# Feature branch: new development
git checkout -b feature/add-fragile-state-comparator

# Make changes, commit often
git add R/utils_data_prep.R tests/testthat/test-utils_data_prep.R
git commit -m "Add fragile state comparator function with tests"

# Push to remote
git push origin feature/add-fragile-state-comparator

# Create pull request on GitHub
# After review and approval, merge to main
```

### Commit Message Format

```
Add fragile state comparator functionality

- Created prepare_fragile_state_comparators() in utils_data_prep.R
- Updated prepare_plot_data() to include fragile state data
- Added UI selector for fragile state status
- Added 5 tests covering new functionality
- Updated documentation

Closes #123
```

### Before Committing

```r
# 1. Run tests
devtools::test()  # Must pass

# 2. Check package
devtools::check()  # Must be clean

# 3. Document
devtools::document()  # Update man/ files

# 4. Format code (optional but recommended)
styler::style_pkg()
```

---

## Release Process

### Version Numbering

Follow semantic versioning (MAJOR.MINOR.PATCH):

```
0.0.0.9000  # Development version
0.1.0       # First minor release
0.1.1       # Patch release (bug fixes)
0.2.0       # New features (minor)
1.0.0       # Major release (breaking changes or stable)
```

### Release Checklist

**1. Prepare Release:**
```r
# Update version in DESCRIPTION
# Version: 0.1.0

# Update NEWS.md
# # cpiaapp 0.1.0
#
# ## New Features
# - Added fragile state comparators
# - Improved validation error messages
#
# ## Bug Fixes
# - Fixed table export for special characters
#
# ## Breaking Changes
# - None

# Run full checks
devtools::test()
devtools::check()
devtools::check_win_devel()  # Check on Windows
```

**2. Tag Release:**
```bash
git tag -a v0.1.0 -m "Release version 0.1.0"
git push origin v0.1.0
```

**3. Create GitHub Release:**
- Go to GitHub → Releases → Draft new release
- Select tag v0.1.0
- Title: "cpiaapp 0.1.0"
- Description: Copy from NEWS.md
- Publish release

**4. Deploy to Production:**
```r
rsconnect::deployApp(
  appTitle = "CPIA Dashboard v0.1.0",
  forceUpdate = TRUE
)
```

**5. Notify Stakeholders:**
- Email users about new version
- Highlight new features
- Link to deployment URL

---

**Next:** [Dependencies & Risk](Dependencies-&-Risk) →
