# Module Reference

Complete API reference for all 19 helper functions in cpiaapp, organized by module.

## Quick Navigation

- [utils_metadata.R](#utils_metadatar) - Question labels & formatting (3 functions)
- [utils_data.R](#utils_datar) - Dataset validation (1 function)
- [utils_data_prep.R](#utils_data_prepr) - Data preparation (6 functions)
- [utils_plot.R](#utils_plotr) - Visualization pipeline (5 functions)
- [utils_table.R](#utils_tabler) - Table generation (2 functions)
- [utils_ui.R](#utils_uir) - Empty state components (2 functions)

---

## utils_metadata.R

Functions for loading and formatting CPIA question metadata.

### get_cpia_questions()

Loads CPIA question metadata from cpiaetl package.

**Signature:**
```r
get_cpia_questions()
```

**Parameters:** None

**Returns:** Tibble with columns:
- `question_id` (character): Question codes (q12a, q12b, etc.)
- `question_label` (character): Full question text
- `cluster_subcategory` (character): Governance subcategory

**Example:**
```r
questions <- get_cpia_questions()
head(questions, 3)
# # A tibble: 3 × 3
#   question_id question_label                          cluster_subcategory
#   <chr>       <chr>                                   <chr>
# 1 q12a        Property rights and rule-based govern…  Property Rights
# 2 q12b        Quality of budgetary and financial ma…  Financial Management
# 3 q13a        Efficiency of revenue mobilization      Revenue Mobilization
```

**Notes:**
- Reads from `system.file("extdata", "cpia_defns.csv", package = "cpiaetl")`
- Returns 13 governance questions (Cluster D)
- Dynamic - automatically reflects cpiaetl updates

---

### get_governance_questions()

Extracts governance-specific questions (Cluster D).

**Signature:**
```r
get_governance_questions()
```

**Parameters:** None

**Returns:** Tibble with governance questions only (filtered from `get_cpia_questions()`)

**Example:**
```r
gov_questions <- get_governance_questions()
nrow(gov_questions)  # 13 questions
```

**Notes:**
- Currently returns same as `get_cpia_questions()` (all questions are Cluster D)
- Useful if future versions include non-governance questions

---

### format_question_choices()

Formats questions for use in Shiny selectInput dropdown.

**Signature:**
```r
format_question_choices()
```

**Parameters:** None

**Returns:** Named character vector:
- Names: Full question labels with Q-code prefix
- Values: Question IDs (q12a, q12b, etc.)

**Example:**
```r
choices <- format_question_choices()
names(choices)[1:3]
# [1] "Q12a: Property rights and rule-based governance"
# [2] "Q12b: Quality of budgetary and financial management"
# [3] "Q13a: Efficiency of revenue mobilization"

choices[1:3]
#                    Q12a: Property rights and rule-based governance
#                                                              "q12a"
#           Q12b: Quality of budgetary and financial management
#                                                              "q12b"
#                           Q13a: Efficiency of revenue mobilization
#                                                              "q13a"
```

**Usage in UI:**
```r
selectInput(
  "question",
  "Select Question:",
  choices = format_question_choices()
)
```

---

## utils_data.R

Functions for validating dataset structure and quality.

### validate_datasets()

Validates all CPIA datasets at app startup.

**Signature:**
```r
validate_datasets(standard_data, africaii_data, 
                  group_standard_data, group_africaii_data)
```

**Parameters:**
- `standard_data`: Standard CPIA country-level data
- `africaii_data`: African Integrity Indicators country-level data
- `group_standard_data`: Standard CPIA group aggregates
- `group_africaii_data`: African Integrity group aggregates

**Returns:** `TRUE` invisibly if all validations pass. Throws error if any validation fails.

**Validations Performed:**
1. NULL and type checks (must be data.frame)
2. Required columns by dataset type:
   - Country data: economy, cpia_year, region, income_group
   - Group data: group, cpia_year, group_type
3. At least one question column matching `^q\d+[a-z]?$`

**Example:**
```r
# Valid datasets
validate_datasets(
  cpiaetl::standard_cpia,
  cpiaetl::africaii_cpia,
  cpiaetl::group_standard_cpia,
  cpiaetl::group_africaii_cpia
)
# Returns TRUE invisibly

# Invalid dataset (missing columns)
bad_data <- tibble(x = 1:10)
validate_datasets(bad_data, good2, good3, good4)
# Error: standard_data is missing required columns: economy, cpia_year, region, income_group
```

**Error Message Format:**
```
standard_data is missing required columns: economy, region.
Expected columns: economy, cpia_year, region, income_group
Found columns: country, year, income, q12a, q12b, ...
```

**See Also:** [Validation System](Validation-System) for detailed documentation

---

## utils_data_prep.R

Functions for preparing and transforming CPIA data for visualization.

### prepare_country_data()

Extracts and formats data for the selected country.

**Signature:**
```r
prepare_country_data(data, selected_country, question)
```

**Parameters:**
- `data`: CPIA dataset (standard_cpia or africaii_cpia)
- `selected_country` (character): Country name (e.g., "Kenya")
- `question` (character): Question ID (e.g., "q12a")

**Returns:** Tibble with columns:
- `economy`, `year`, `score`, `region`, `income_group`
- `group_type` = "Selected Country"
- `display_name` = country name
- `line_type` = "solid"

**Example:**
```r
result <- prepare_country_data(cpiaetl::standard_cpia, "Kenya", "q12a")

# Result structure:
# # A tibble: 10 × 8
#   economy  year score region           income_group group_type display_name line_type
#   <chr>   <dbl> <dbl> <chr>            <chr>        <chr>      <chr>        <chr>
# 1 Kenya    2015   3.5 Sub-Saharan Af…  Low income   Selected…  Kenya        solid
# 2 Kenya    2016   3.5 Sub-Saharan Af…  Low income   Selected…  Kenya        solid
# ...
```

**Validation:** Errors if question not found in data, showing available questions.

---

### prepare_region_comparators()

Prepares regional average data for comparison.

**Signature:**
```r
prepare_region_comparators(group_data, selected_regions, question)
```

**Parameters:**
- `group_data`: Group aggregate dataset (group_standard_cpia or group_africaii_cpia)
- `selected_regions` (character vector): Region names (e.g., c("Sub-Saharan Africa", "South Asia"))
- `question` (character): Question ID

**Returns:** Tibble with regional averages, `line_type` = "dashed". Returns empty tibble if `selected_regions` is NULL or empty.

**Example:**
```r
result <- prepare_region_comparators(
  cpiaetl::group_standard_cpia,
  c("Sub-Saharan Africa", "South Asia"),
  "q12a"
)

# Result structure:
# # A tibble: 20 × 7
#   group              year score group_type display_name           line_type comparator_category
#   <chr>             <dbl> <dbl> <chr>      <chr>                  <chr>     <chr>
# 1 Sub-Saharan Af…    2015   3.2 region     Sub-Saharan Africa     dashed    region
# 2 Sub-Saharan Af…    2016   3.3 region     Sub-Saharan Africa     dashed    region
# ...
```

---

### prepare_income_comparators()

Prepares income group average data for comparison.

**Signature:**
```r
prepare_income_comparators(group_data, selected_income_groups, question)
```

**Parameters:**
- `group_data`: Group aggregate dataset
- `selected_income_groups` (character vector): Income group names (e.g., c("Low income", "Lower middle income"))
- `question` (character): Question ID

**Returns:** Tibble with income group averages, `line_type` = "dashed". Returns empty tibble if `selected_income_groups` is NULL or empty.

**Example:**
```r
result <- prepare_income_comparators(
  cpiaetl::group_standard_cpia,
  c("Low income", "Upper middle income"),
  "q12a"
)
```

**Note:** Uses internal helper `prepare_group_comparators()` with `category_type = "income_group"`

---

### prepare_country_comparators()

Prepares data for custom country comparisons.

**Signature:**
```r
prepare_country_comparators(data, custom_countries, question)
```

**Parameters:**
- `data`: CPIA dataset (standard_cpia or africaii_cpia)
- `custom_countries` (character vector): Country names (e.g., c("Tanzania", "Uganda", "Rwanda"))
- `question` (character): Question ID

**Returns:** Tibble with custom country data, `line_type` = "dashed". Returns empty tibble if `custom_countries` is NULL or empty.

**Example:**
```r
result <- prepare_country_comparators(
  cpiaetl::standard_cpia,
  c("Tanzania", "Uganda", "Rwanda"),
  "q12a"
)

# Result structure:
# # A tibble: 30 × 8
#   economy   year score region          income_group group_type display_name line_type
#   <chr>    <dbl> <dbl> <chr>           <chr>        <chr>      <chr>        <chr>
# 1 Tanzania  2015   3.8 Sub-Saharan Af… Low income   Custom Co… Tanzania     dashed
# 2 Tanzania  2016   3.9 Sub-Saharan Af… Low income   Custom Co… Tanzania     dashed
# ...
```

**Validation:** Errors if question not found in data.

---

### prepare_plot_data()

Orchestrator function that combines all comparator types.

**Signature:**
```r
prepare_plot_data(data, group_data, selected_country, question,
                  selected_regions = NULL, selected_income_groups = NULL,
                  custom_countries = NULL)
```

**Parameters:**
- `data`: Country-level CPIA dataset
- `group_data`: Group aggregate dataset
- `selected_country` (character): Country to analyze
- `question` (character): Question ID
- `selected_regions` (character vector, optional): Regions to compare
- `selected_income_groups` (character vector, optional): Income groups to compare
- `custom_countries` (character vector, optional): Countries to compare

**Returns:** Combined tibble with all selected data ready for plotting.

**Example:**
```r
plot_data <- prepare_plot_data(
  data = cpiaetl::standard_cpia,
  group_data = cpiaetl::group_standard_cpia,
  selected_country = "Kenya",
  question = "q12a",
  selected_regions = "Sub-Saharan Africa",
  selected_income_groups = "Low income",
  custom_countries = c("Tanzania", "Uganda")
)

# Result combines:
# - Kenya (solid line)
# - Sub-Saharan Africa average (dashed)
# - Low income average (dashed)
# - Tanzania (dashed)
# - Uganda (dashed)
```

**Data Flow:**
```
prepare_plot_data()
  ├─ prepare_country_data()        → Selected country
  ├─ prepare_region_comparators()  → Regional averages
  ├─ prepare_income_comparators()  → Income averages
  └─ prepare_country_comparators() → Custom countries
  ↓
bind_rows() combines all tibbles
  ↓
arrange(economy, year) for consistent ordering
```

---

## utils_plot.R

Functions for creating interactive CPIA visualizations.

### create_plot_styling()

Maps data to ggplot aesthetics (colors, line types, legend order).

**Signature:**
```r
create_plot_styling(data)
```

**Parameters:**
- `data`: Prepared plot data (output from `prepare_plot_data()`)

**Returns:** List with:
- `color_mapping`: Named vector mapping display_name → color
- `linetype_mapping`: Named vector mapping display_name → line type
- `legend_order`: Character vector of display names in plot order

**Example:**
```r
styling <- create_plot_styling(plot_data)

styling$color_mapping
# Named vector:
#      Kenya     Sub-Saharan Africa          Low income
#  "#1f77b4"            "#ff7f0e"            "#2ca02c"  ...

styling$linetype_mapping
# Named vector:
#      Kenya     Sub-Saharan Africa          Low income
#    "solid"             "dashed"             "dashed"  ...

styling$legend_order
# [1] "Kenya" "Sub-Saharan Africa" "Low income" "Tanzania" "Uganda"
```

**Notes:**
- Selected country always gets first color and solid line
- Comparators get subsequent colors and dashed lines
- Legend order: selected country first, then comparators alphabetically

---

### create_base_plot()

Creates the base ggplot2 time-series visualization.

**Signature:**
```r
create_base_plot(data, styling, question_label)
```

**Parameters:**
- `data`: Prepared plot data
- `styling`: Output from `create_plot_styling()`
- `question_label` (character): Full question text for plot title

**Returns:** ggplot object

**Example:**
```r
p <- create_base_plot(plot_data, styling, "Property rights and rule-based governance")

# Creates time-series plot with:
# - x-axis: year
# - y-axis: score
# - color: display_name
# - linetype: line_type
# - Legend at bottom with 11pt text
```

**Plot Features:**
- Time-series line plot with points
- Legend at bottom, horizontal orientation
- 11pt legend text size (for readability)
- Automatic axis scaling

---

### apply_plot_theme()

Applies bslib and thematic styling for Shiny integration.

**Signature:**
```r
apply_plot_theme(plot)
```

**Parameters:**
- `plot`: ggplot object (output from `create_base_plot()`)

**Returns:** Styled ggplot object

**Example:**
```r
p <- create_base_plot(...) |> apply_plot_theme()
```

**Styling Applied:**
- bslib theme integration (matches Shiny app theme)
- thematic automatic styling (colors, fonts)
- Maintains 11pt legend text from base plot

---

### convert_to_plotly()

Converts ggplot to interactive plotly visualization.

**Signature:**
```r
convert_to_plotly(plot)
```

**Parameters:**
- `plot`: Styled ggplot object

**Returns:** plotly htmlwidget

**Example:**
```r
interactive_plot <- create_base_plot(...) |>
  apply_plot_theme() |>
  convert_to_plotly()
```

**Interactive Features:**
- Hover tooltips showing exact values
- Zoom and pan capabilities
- Legend toggle (click to show/hide series)
- Export to PNG

---

### create_cpia_plot()

Complete plotting pipeline (orchestrator function).

**Signature:**
```r
create_cpia_plot(data, question_label)
```

**Parameters:**
- `data`: Prepared plot data (output from `prepare_plot_data()`)
- `question_label` (character): Full question text

**Returns:** plotly htmlwidget ready for Shiny rendering

**Example:**
```r
plot <- create_cpia_plot(plot_data, "Property rights and rule-based governance")

# In Shiny server:
output$cpia_plot <- plotly::renderPlotly({
  create_cpia_plot(prepared_data, question_label)
})
```

**Pipeline:**
```
create_cpia_plot(data, label)
  ├─ create_plot_styling(data)
  ├─ create_base_plot(data, styling, label)
  ├─ apply_plot_theme(plot)
  └─ convert_to_plotly(plot)
  ↓
Interactive plotly visualization
```

---

## utils_table.R

Functions for creating interactive data tables.

### prepare_table_data()

Transforms plot data into wide format for tabulation.

**Signature:**
```r
prepare_table_data(data)
```

**Parameters:**
- `data`: Prepared plot data (output from `prepare_plot_data()`)

**Returns:** Tibble in Year × Name format with rounded scores (1 decimal)

**Example:**
```r
table_data <- prepare_table_data(plot_data)

# Result structure:
# # A tibble: 10 × 6
#    Year Kenya `Sub-Saharan Africa` `Low income` Tanzania Uganda
#   <dbl> <dbl>                <dbl>        <dbl>    <dbl>  <dbl>
# 1  2015   3.5                  3.2          3.0      3.8    3.6
# 2  2016   3.5                  3.3          3.1      3.9    3.7
# ...
```

**Transformations:**
1. Select `year`, `display_name`, `score`
2. Remove duplicates with `distinct()`
3. Pivot wider: Year × Name
4. Handle duplicates with `mean()` aggregation
5. Round scores to 1 decimal place

---

### create_cpia_table()

Creates interactive DT table with export capabilities.

**Signature:**
```r
create_cpia_table(data)
```

**Parameters:**
- `data`: Prepared plot data

**Returns:** DT htmlwidget ready for Shiny rendering

**Example:**
```r
table <- create_cpia_table(plot_data)

# In Shiny server:
output$cpia_table <- DT::renderDT({
  create_cpia_table(prepared_data)
})
```

**Table Features:**
- Export buttons: Copy, CSV, Excel, PDF
- Pagination (10 rows per page)
- Search/filter functionality
- Sortable columns
- Rounded values (1 decimal)

---

## utils_ui.R

Functions for empty state UI components.

### create_empty_plot_message()

Creates placeholder plot for empty data scenarios.

**Signature:**
```r
create_empty_plot_message(message = "No Data Available...")
```

**Parameters:**
- `message` (character, optional): Custom message text. Defaults to "No Data Available. Please make a selection above."

**Returns:** plotly htmlwidget with message

**Example:**
```r
# Default message
empty_plot <- create_empty_plot_message()

# Custom message
empty_plot <- create_empty_plot_message("Select a country to begin analysis")

# In Shiny server:
output$plot <- plotly::renderPlotly({
  if (nrow(prepared_data) == 0) {
    create_empty_plot_message()
  } else {
    create_cpia_plot(prepared_data, question_label)
  }
})
```

**Features:**
- Centered text annotation
- No axes or gridlines
- Clean, minimal appearance
- Consistent with app theme

---

### create_empty_table_message()

Creates placeholder table for empty data scenarios.

**Signature:**
```r
create_empty_table_message(message = "No Data Available...")
```

**Parameters:**
- `message` (character, optional): Custom message text

**Returns:** DT htmlwidget with message

**Example:**
```r
# Default message
empty_table <- create_empty_table_message()

# Custom message
empty_table <- create_empty_table_message("No comparators selected")

# In Shiny server:
output$table <- DT::renderDT({
  if (nrow(prepared_data) == 0) {
    create_empty_table_message()
  } else {
    create_cpia_table(prepared_data)
  }
})
```

---

## Function Dependencies

### Dependency Graph

```
run_cpiaapp()
  ├─ validate_datasets() [utils_data.R]
  │
  ├─ viz_ui()
  │    └─ format_question_choices() [utils_metadata.R]
  │         └─ get_cpia_questions() [utils_metadata.R]
  │
  └─ viz_server()
       ├─ prepare_plot_data() [utils_data_prep.R]
       │    ├─ prepare_country_data()
       │    ├─ prepare_region_comparators()
       │    │    └─ prepare_group_comparators() [internal]
       │    ├─ prepare_income_comparators()
       │    │    └─ prepare_group_comparators() [internal]
       │    └─ prepare_country_comparators()
       │
       ├─ create_cpia_plot() [utils_plot.R]
       │    ├─ create_plot_styling()
       │    ├─ create_base_plot()
       │    ├─ apply_plot_theme()
       │    └─ convert_to_plotly()
       │
       ├─ create_cpia_table() [utils_table.R]
       │    └─ prepare_table_data()
       │
       ├─ create_empty_plot_message() [utils_ui.R]
       └─ create_empty_table_message() [utils_ui.R]
```

---

**Next:** [Testing Guide](Testing-Guide) →
