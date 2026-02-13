# Prompt: Create R Package Vignette

## Purpose
Generate a user-focused R vignette (tutorial) that teaches users how to use your R package effectively, with executable examples and clear explanations.

## Context
- **Package Name**: {package-name}
- **Package Type**: [Shiny app / Data package / Analysis package / Utility package]
- **Primary Use Cases**: [List 2-3 main use cases]
- **Target Audience**: [Data analysts / Researchers / Developers / Domain experts]
- **Key Functions**: [List 3-5 main functions users will use]
- **Data Requirements**: [What data do users need? Included or external?]

## Vignette Structure

Create an R Markdown (.Rmd) vignette with the following structure:

### 1. YAML Header

```yaml
---
title: "{Descriptive Title for Use Case}"
author: "{Author Name or Package Maintainers}"
date: "`r Sys.Date()`"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{{Descriptive Title}}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---
```

### 2. Introduction

```markdown
## Introduction

{Brief overview of what this vignette teaches}

**What you'll learn:**
- {Learning objective 1}
- {Learning objective 2}
- {Learning objective 3}

**Prerequisites:**
- {Prerequisite 1 - e.g., "Basic R knowledge"}
- {Prerequisite 2 - e.g., "Familiarity with ggplot2"}
```

### 3. Setup

```r
```{r setup, include = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5
)
```

```{r load-packages}
library({package-name})
# Other packages used in examples
library(dplyr)
library(ggplot2)
```
```

### 4. Main Content Sections

Organize by use case or workflow:

#### Pattern A: For Shiny App Packages

```markdown
## Launching the Application

{Explain how to start the app}

```{r launch-app, eval = FALSE}
run_{app_name}()
```

## Understanding the Interface

{Describe UI components with screenshots}

![Dashboard overview](figures/dashboard-screenshot.png)

## Example Workflow: {Specific Task}

{Walk through a complete analysis task}

### Step 1: {Action}
{Explanation of what user should do}

### Step 2: {Action}
{Explanation with expected results}

### Step 3: {Action}
{Showing final output}

## Interpreting Results

{How to understand and use the output}

## Common Scenarios

### Scenario 1: {Use Case}
{Step-by-step guide}

### Scenario 2: {Use Case}
{Step-by-step guide}
```

#### Pattern B: For Data Packages

```markdown
## Available Datasets

{Overview of included datasets}

```{r list-datasets}
data(package = "{package-name}")
```

## Dataset: {dataset_name}

{Description of dataset purpose and contents}

```{r load-data}
data({dataset_name}, package = "{package-name}")
head({dataset_name})
```

### Data Structure

```{r explore-structure}
str({dataset_name})
summary({dataset_name})
```

### Column Descriptions

| Column | Type | Description |
|--------|------|-------------|
| {col1} | {type} | {description} |
| {col2} | {type} | {description} |

## Example Analysis: {Research Question}

{Step-by-step analysis with executable code}

```{r analysis-1}
# Data preparation
prepared_data <- {dataset_name} |>
  filter(...) |>
  mutate(...)

# Visualization
ggplot(prepared_data, aes(...)) +
  geom_...() +
  labs(...)
```

{Interpretation of results}
```

#### Pattern C: For Analysis Packages

```markdown
## Basic Usage

{Simplest possible example}

```{r basic-example}
# Load example data
data(example_data)

# Apply main function
result <- {main_function}(example_data, parameters)

# View results
summary(result)
```

## Understanding the Method

{Explain the statistical/analytical method in plain language}

## Customizing Parameters

{Explain key parameters and when to adjust}

```{r custom-parameters}
# Default parameters
result_default <- {function}(data)

# Custom parameters
result_custom <- {function}(
  data,
  param1 = value1,  # Explanation
  param2 = value2   # Explanation
)

# Compare results
plot(result_default)
plot(result_custom)
```

## Advanced Example: {Complex Use Case}

{Multi-step analysis showing package in realistic scenario}

```{r advanced-example}
# Step 1: Data preparation
...

# Step 2: Model fitting
...

# Step 3: Diagnostics
...

# Step 4: Interpretation
...
```

## Interpreting Results

{Guide to understanding output}

### Key Metrics
- **{Metric 1}**: {What it means}
- **{Metric 2}**: {What it means}

### Diagnostic Plots
{How to read plots produced by package}
```

#### Pattern D: For Utility Packages

```markdown
## Quick Start

{Minimal example showing package value}

```{r quick-start}
{minimal_working_example}
```

## Function Category: {Category Name}

{Group related functions together}

### {Function Name}

{Purpose and use case}

```{r function-example-1}
# Basic usage
result <- {function_name}(input)

# With options
result <- {function_name}(
  input,
  option1 = TRUE,
  option2 = "value"
)
```

## Chaining Functions

{Show how functions work together}

```{r pipeline-example}
result <- data |>
  {function1}() |>
  {function2}() |>
  {function3}()
```

## Integration with Other Packages

{Show how package complements popular tools}

```{r integration}
# With dplyr
data |>
  {package_function}() |>
  filter(...) |>
  summarize(...)

# With ggplot2
{package_function}(data) |>
  ggplot(aes(...)) +
  geom_...()
```
```

### 5. Troubleshooting Section

```markdown
## Troubleshooting

### Common Issues

**Issue 1: {Error or Problem}**

{Explanation of cause}

```{r troubleshooting-1, eval = FALSE}
# ❌ This will error
{bad_example}

# ✅ Correct approach
{good_example}
```

**Issue 2: {Error or Problem}**

{Explanation and solution}

### Getting Help

{How to get support}

- `?{function_name}` - Function documentation
- `vignette("{package-name}")` - This vignette
- [GitHub Issues]({repo_url}/issues) - Report bugs
- [{documentation_url}]({url}) - Full documentation
```

### 6. Summary and Next Steps

```markdown
## Summary

**What we covered:**
- {Summary point 1}
- {Summary point 2}
- {Summary point 3}

**Key functions:**
- `{function1}()` - {Purpose}
- `{function2}()` - {Purpose}
- `{function3}()` - {Purpose}

## Next Steps

**To learn more:**
- {Next learning resource 1}
- {Next learning resource 2}
- {Next learning resource 3}

**Example datasets:** The package includes {data_name} dataset for practice. Access with `data({data_name})`.

**Advanced topics:** See [GitHub Wiki]({wiki_url}) for:
- {Advanced topic 1}
- {Advanced topic 2}
```

### 7. References (if applicable)

```markdown
## References

{List academic papers, methodology sources, or related resources}

- Author, A. (Year). Title. *Journal*, vol(issue), pages.
- [Method Name]({url}) - Documentation
```

### 8. Session Info

```{r session-info}
sessionInfo()
```

## Vignette Types by Package

### For Shiny Apps:
- **Title**: "Using the {App Name} Dashboard"
- **Focus**: User interface walkthrough
- **Examples**: Non-executable (screenshots, descriptions)
- **Sections**: Launching, Interface tour, Workflows, Interpreting output

### For Data Packages:
- **Title**: "Analyzing {Domain} Data with {Package}"
- **Focus**: Dataset exploration and analysis examples
- **Examples**: All executable with included data
- **Sections**: Data overview, Structure, Analysis workflows, Interpretation

### For Analysis Packages:
- **Title**: "Introduction to {Method} with {Package}"
- **Focus**: Methodology and application
- **Examples**: Mix of toy data and realistic scenarios
- **Sections**: Method overview, Basic usage, Customization, Advanced examples

### For Utility Packages:
- **Title**: "{Package}: {Key Functionality} in R"
- **Focus**: Function demonstrations and patterns
- **Examples**: Short, focused code snippets
- **Sections**: Quick start, Function categories, Pipelines, Integration

## File Location

```
vignettes/
├── {package-name}.Rmd          # Main/intro vignette
├── {advanced-topic}.Rmd         # Advanced vignette (optional)
└── figures/                     # Screenshots and diagrams
    ├── screenshot-1.png
    └── diagram-1.png
```

## Writing Guidelines

### Code Chunks:
```r
# Good chunk options
```{r chunk-name, eval = TRUE, echo = TRUE, message = FALSE, warning = FALSE}
# Code here
```

# For long output, show only first few lines
```{r chunk-name, eval = TRUE}
result <- long_operation()
head(result)  # Instead of printing all
```

# For plots
```{r plot-name, fig.width = 7, fig.height = 5, fig.cap = "Descriptive caption"}
# Plot code
```

# For non-executable examples (Shiny apps)
```{r shiny-example, eval = FALSE}
run_app()
```
```

### Writing Style:
- **Conversational but professional** ("Let's explore..." not "One must examine...")
- **Step-by-step instructions** (numbered or bulleted)
- **Explain the "why"** (not just the "how")
- **Show expected output** (after code chunks)
- **Use real-world scenarios** (not abstract examples)
- **Progressive complexity** (simple → advanced)

### Code Examples:
- **Executable** (use eval = TRUE by default)
- **Self-contained** (define all variables in vignette)
- **Commented** (explain non-obvious code)
- **Realistic** (show actual use cases)
- **Consistent style** (follow tidyverse guide)

## Building and Testing

### Build vignette locally:
```r
# Build all vignettes
devtools::build_vignettes()

# View vignette
browseVignettes("{package-name}")
```

### Check vignette builds correctly:
```r
devtools::check(vignettes = TRUE)
```

## Validation Checklist

- [ ] YAML header complete and correct
- [ ] All code chunks execute without error
- [ ] Figures display correctly
- [ ] Output is readable and formatted
- [ ] Examples use included data (or explain external data needs)
- [ ] Code follows package style guidelines
- [ ] No hardcoded paths or system-specific code
- [ ] sessionInfo() included at end
- [ ] Vignette builds successfully with `devtools::build_vignettes()`
- [ ] Appropriate length (2000-5000 words typical)
- [ ] Clear learning progression (simple → complex)
- [ ] All functions referenced are exported

## Example Invocation

"Create an R vignette for cpiaapp, a Shiny dashboard package for CPIA governance indicators. The vignette should walk users through launching the app, selecting countries and questions, adding comparators (regional, income group, custom countries), and interpreting the time-series plots and data tables. Target audience is data analysts and researchers analyzing governance trends. Include screenshots of the interface and explain what each selection does."

---

**Related Prompts:**
- `create-readme.prompt.md` - For package overview
- `create-github-wiki.prompt.md` - For technical documentation
