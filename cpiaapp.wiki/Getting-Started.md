# Getting Started

This guide will help you install, run, and understand the basic structure of the cpiaapp package.

## Installation

### From GitHub

```r
# Install devtools if you don't have it
install.packages("devtools")

# Install cpiaapp from GitHub
devtools::install_github("WB-PIDA-Data-Science-Shop/cpiaapp")
```

### For Development

If you're contributing to the package:

```r
# Clone the repository
git clone https://github.com/WB-PIDA-Data-Science-Shop/cpiaapp.git
cd cpiaapp

# Open in RStudio or your preferred IDE
# Install dependencies
devtools::install_deps()

# Load the package for development
devtools::load_all()
```

## Running the App

### Basic Usage

```r
library(cpiaapp)
run_cpiaapp()
```

The dashboard will open in your default web browser at `http://127.0.0.1:XXXX`.

### Testing During Development

```r
# Load latest code changes
devtools::load_all()

# Run the app
run_cpiaapp()
```

The app automatically loads datasets from the `cpiaetl` package:
- **standard_cpia** - Standard CPIA governance indicators
- **africaii_cpia** - African Integrity Indicators
- **group_standard_cpia** - Regional and income group aggregates for standard CPIA
- **group_africaii_cpia** - Regional and income group aggregates for African Integrity

## Project Structure

### Directory Layout

```
cpiaapp/
├── R/                          # R source code
│   ├── run_cpiaapp.R          # Main app launcher
│   ├── viz_server.R           # Server orchestration (132 lines)
│   ├── viz_ui.R               # User interface (90 lines)
│   ├── utils_metadata.R       # Question labels & formatting (3 functions)
│   ├── utils_data.R           # Dataset validation (1 function)
│   ├── utils_data_prep.R      # Data preparation pipeline (6 functions)
│   ├── utils_plot.R           # Plotting functions (5 functions)
│   ├── utils_table.R          # Table generation (2 functions)
│   └── utils_ui.R             # Empty state components (2 functions)
│
├── tests/                      # Test suite (134 tests)
│   └── testthat/
│       ├── test-utils_metadata.R      # 25 tests
│       ├── test-utils_data.R          # 17 tests
│       ├── test-utils_ui.R            # 9 tests
│       ├── test-utils_data_prep.R     # 48 tests
│       ├── test-utils_plot.R          # 18 tests
│       ├── test-utils_table.R         # 17 tests
│       └── test-app_integration.R     # 6 tests (shinytest2)
│
├── inst/                       # Installed files
│   ├── www/                   # Web assets
│   │   ├── cpia_logo.png     # Dashboard logo
│   │   └── styles.css        # Custom CSS
│   └── markdown/
│       └── cpia_home.md      # Home page content
│
├── man/                        # Generated documentation
├── DESCRIPTION                 # Package metadata
├── NAMESPACE                   # Exported functions (auto-generated)
├── LICENSE                     # MIT license
├── README.md                   # Package overview
├── app.R                       # Deployment entry point
└── cpiaapp.Rproj              # RStudio project file
```

### Key Files Explained

#### `R/run_cpiaapp.R`
Main entry point that:
1. Loads datasets from cpiaetl
2. Validates dataset structure with `validate_datasets()`
3. Launches the Shiny app with UI and server

#### `R/viz_server.R` (132 lines)
Orchestration layer that:
- Manages reactive state (selected country, question, comparators)
- Calls helper functions to prepare data
- Renders plots and tables
- Handles dataset switching (Standard ↔ African Integrity)

#### `R/viz_ui.R` (90 lines)
User interface that:
- Creates navbar with dataset tabs
- Builds control panel for selections (country, question, comparators)
- Displays plot and table outputs
- Uses formatted question choices from `format_question_choices()`

#### `R/utils_*.R` (6 modules)
Helper function libraries organized by purpose:
- **metadata** - Question labels and formatting
- **data** - Dataset validation
- **data_prep** - Data preparation pipeline
- **plot** - ggplot2 → plotly visualization
- **table** - DT interactive tables
- **ui** - Empty state UI components

## Understanding the App Flow

### 1. User Interaction
```
User selects:
  ├─ Country (e.g., "Kenya")
  ├─ Question (e.g., "Property rights and rule-based governance")
  └─ Comparators:
      ├─ Regions (e.g., "Sub-Saharan Africa")
      ├─ Income groups (e.g., "Low income")
      └─ Custom countries (e.g., "Tanzania", "Uganda")
```

### 2. Data Preparation
```r
prepare_plot_data(data, group_data, country, question, regions, income, countries)
  ↓
  ├─ prepare_country_data() → Selected country with solid line
  ├─ prepare_region_comparators() → Regional averages with dashed lines
  ├─ prepare_income_comparators() → Income group averages with dashed lines
  └─ prepare_country_comparators() → Custom countries with dashed lines
  ↓
Combined tibble ready for plotting
```

### 3. Visualization
```r
create_cpia_plot(plot_data, question_label)
  ↓
  ├─ create_plot_styling() → Colors, line types, legend
  ├─ create_base_plot() → ggplot2 time-series
  ├─ apply_plot_theme() → bslib/thematic styling
  └─ convert_to_plotly() → Interactive tooltips
  ↓
Plotly htmlwidget displayed in app
```

### 4. Tabulation
```r
create_cpia_table(plot_data)
  ↓
  ├─ prepare_table_data() → Pivot to Year × Name format
  └─ DT::datatable() → Interactive table with export buttons
  ↓
DT htmlwidget displayed in app
```

## First Steps After Installation

### 1. Verify Installation
```r
library(cpiaapp)
?run_cpiaapp  # View documentation
```

### 2. Run the App
```r
run_cpiaapp()
```

### 3. Explore Available Questions
```r
devtools::load_all()
questions <- get_cpia_questions()
print(questions)
# Should show 13 questions: q12a-q16d (including q13c)
```

### 4. Run Tests
```r
devtools::test()
# Should see: Test passed ✔ | 134 | 6 skipped
```

### 5. Check Package Health
```r
devtools::check()
# Should see: 0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```

## Common Issues

### Missing cpiaetl Package
**Error:** `there is no package called 'cpiaetl'`

**Solution:**
```r
# Install cpiaetl from your organization's repository
# Contact PIDA Data Science Shop for access
```

### Integration Tests Skipped
**Message:** `Reason: Chrome not available (group policy or processx limitation)`

**Explanation:** This is expected in corporate environments with restricted Chrome access. The 6 integration tests will skip gracefully. Unit tests (128 tests) still provide comprehensive coverage.

### Port Already in Use
**Error:** `Error in startServer: Failed to create server`

**Solution:** Shiny is already running on that port. Stop the other Shiny app or restart R session.

## Next Steps

Now that you have the app running:

1. **Understand the Architecture** → [Architecture & Design](Architecture-&-Design)
2. **Explore the Code** → [Module Reference](Module-Reference)
3. **Learn to Test** → [Testing Guide](Testing-Guide)
4. **Make Changes** → [Development Workflow](Development-Workflow)

## Getting Help

- **Documentation:** This wiki covers most scenarios
- **Function Help:** Use `?function_name` in R
- **Issues:** Report bugs on [GitHub Issues](https://github.com/WB-PIDA-Data-Science-Shop/cpiaapp/issues)
- **Questions:** Contact PIDA Data Science Shop

---

**Next:** [Architecture & Design](Architecture-&-Design) →
