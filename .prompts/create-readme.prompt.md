# Prompt: Create Comprehensive Package README

## Purpose
Generate a comprehensive, well-structured README.md that serves as the entry point for users and developers discovering your R package (Shiny or non-Shiny).

## Context
- **Package Type**: [Shiny app package / Data package / Analysis package / Utility package]
- **Target Audience**: [End users / Data analysts / Developers / Researchers]
- **Key Features**: [List 3-5 main features]
- **Current State**: [Development / Production-ready / Experimental]

## Instructions

Create a README.md with the following sections, adapting content based on package type:

### 1. Header & Badges
```markdown
# {package-name}

[![R CMD Check](https://img.shields.io/badge/R%20CMD%20check-passing-brightgreen)]
[![Coverage](https://img.shields.io/badge/coverage-XX%25-brightgreen)]

One-sentence description of what the package does.

![Screenshot or Logo](path/to/image.png)
```

### 2. "What Does This Do?" Section
- **For Shiny apps**: Explain user-facing capabilities with bullet points
- **For data packages**: Describe datasets included and their uses
- **For analysis packages**: Summarize analytical methods provided
- **For utility packages**: List key functions and use cases

Use emoji bullets (📊 🌍 💰 🔀 📋) for Shiny apps to make features scannable.

### 3. Quick Start
```markdown
## Quick Start

```r
# Installation
devtools::install_github("org/package")

# Basic usage (adapt to package type)
library(package)
{primary-function}()  # For Shiny: run_app()
```
```

### 4. Features List
✅ Use checkmarks for completed features
📝 Include key metrics (number of functions, tests, etc.)
🎯 Highlight unique capabilities

### 5. Architecture Overview (if complex)
```markdown
## Package Architecture

{Brief description of how code is organized}

```
{Layer 1: User-facing functions}
     ↓
{Layer 2: Processing/business logic}
     ↓
{Layer 3: Data/helpers}
```

**Result:** {Brief benefit statement}
```

### 6. Documentation Links
```markdown
## Documentation

📚 **[GitHub Wiki](../../wiki)** - Comprehensive technical documentation
- [Architecture & Design](../../wiki/Architecture-&-Design)
- [Function Reference](../../wiki/Module-Reference)
- [Testing Guide](../../wiki/Testing-Guide)

📖 **R Documentation** - `?function_name` for detailed help

📝 **Vignette** - Tutorial and examples (`browseVignettes("package")`)
```

### 7. Development Workflow (for contributors)
```markdown
## Development Workflow

### Running Tests
```r
devtools::test()    # Run all tests
devtools::check()   # Full R CMD check
```

### Adding New Features
1. **{Task type}** → Edit {relevant file}
2. **{Task type}** → Edit {relevant file}
3. **Write tests** → Add to `tests/testthat/test-*.R`

See [Development Workflow](../../wiki/Development-Workflow) for detailed guides.
```

### 8. Dependencies
```markdown
## Dependencies

**Core:** {list essential packages with versions}
**Dev:** {list development dependencies}
**R Version:** >= X.X.X {note any specific requirements}
```

### 9. Deployment Section (for Shiny apps only)
```markdown
## Deployment

Deploy to Posit Connect:

```r
rsconnect::deployApp(
  appDir = getwd(),
  appTitle = "{App Title}",
  server = "{your-server}.com"
)
```

See [Deployment Guide](../../wiki/Deployment) for troubleshooting.
```

### 10. Project Status
```markdown
## Project Status

**Version:** X.X.X
**Status:** {Development / Production-ready / Stable}
**Tests:** XXX passing (0 failures)
**R CMD Check:** 0 errors, 0 warnings, 0 notes
```

### 11. Contributing Section
```markdown
## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure `devtools::check()` passes
5. Submit a pull request

See [Contributing Guide](../../wiki/Development-Workflow#contributing) for details.
```

### 12. License & Contact
```markdown
## License

{License type - typically MIT}

## Contact

**Maintainer:** {Name or Organization}
**Repository:** [{org}/{package}](https://github.com/{org}/{package})
```

## Customization Guidelines

### For Shiny App Packages:
- Emphasize user-facing features and screenshots
- Include "Quick Start" with `run_app()` example
- Add deployment section
- Highlight interactivity and visualization

### For Data Packages:
- List datasets with brief descriptions
- Show example data access and structure
- Explain data sources and update frequency
- Include data dictionary links

### For Analysis Packages:
- Summarize statistical methods
- Show example analyses with code
- Reference theoretical foundations
- Link to academic papers if applicable

### For Utility Packages:
- Organize functions by category
- Show practical use cases
- Emphasize code quality and testing
- Include performance comparisons

## Output Format
- Markdown with proper formatting
- Code blocks with syntax highlighting (```r)
- Relative links to wiki pages (../../wiki/{Page-Name})
- Professional tone, concise language
- Scannable structure (headings, bullets, emojis)

## Validation
After generating README:
- [ ] All links work (wiki, repository)
- [ ] Code examples run successfully
- [ ] Images display correctly
- [ ] Badges show accurate information
- [ ] Appropriate length (not too long, not too short)
- [ ] Clear value proposition in first paragraph
- [ ] Navigation to detailed documentation is obvious

## Example Invocation

"Create a comprehensive README for cpiaapp, a Shiny dashboard package that visualizes World Bank CPIA governance indicators. The package is production-ready with 134 passing tests, uses a modular architecture with 6 utility modules, and features interactive plotly visualizations. Target audience: data analysts and researchers analyzing governance scores across countries and time."

---

**Related Prompts:**
- `create-github-wiki.prompt.md` - For detailed technical documentation
- `create-r-vignette.prompt.md` - For user-focused tutorials
