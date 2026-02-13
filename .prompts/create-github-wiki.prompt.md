# Prompt: Create Comprehensive GitHub Wiki Documentation

## Purpose
Generate complete GitHub Wiki documentation that serves as the technical reference for R package maintainers and contributors (Shiny or non-Shiny packages).

## Context
- **Package Type**: [Shiny app / Data package / Analysis package / Utility package]
- **Package Name**: {package-name}
- **Architecture**: [Modular / Monolithic / Pipeline-based]
- **Key Modules**: [List main code modules/files]
- **Test Coverage**: [Number of tests and percentage coverage]
- **Deployment Target**: [Posit Connect / CRAN / Internal / GitHub only]

## Wiki Structure

Create the following wiki pages as separate markdown files in `wiki/` directory:

### 1. Home.md (Wiki Landing Page)

```markdown
# {Package Name} Technical Documentation

Welcome to comprehensive technical documentation for **{package-name}**.

## 📚 Documentation Overview

This wiki provides in-depth technical documentation for developers maintaining, extending, or understanding the {package-name} codebase.

### For New Developers
Start here to understand the package:
1. [Getting Started](Getting-Started) - Installation, running, structure
2. [Architecture & Design](Architecture-&-Design) - Organization and design decisions
3. [Module/Function Reference](Module-Reference) - Detailed API documentation

### For Maintainers
Essential guides for ongoing maintenance:
- [Testing Guide](Testing-Guide) - Running and writing tests
- [{Validation/Quality} System]({Validation-System}) - {Relevant quality aspect}
- [Deployment](Deployment) - {Deployment instructions if applicable}

### For Contributors
Resources for adding new features:
- [Development Workflow](Development-Workflow) - How to add features
- [Code Style Guidelines](Development-Workflow#code-style-guidelines)
- [Dependencies & Risk](Dependencies-&-Risk) - Package dependencies

## 🎯 Quick Links

| Topic | Description | Link |
|-------|-------------|------|
| **What is {package}?** | Overview and capabilities | [Getting Started](Getting-Started) |
| **How does it work?** | Architecture and data flow | [Architecture & Design](Architecture-&-Design) |
| **Function reference** | Complete API documentation | [Module Reference](Module-Reference) |
| **Testing** | Test strategy and execution | [Testing Guide](Testing-Guide) |
| **Development** | Adding features and contributing | [Development Workflow](Development-Workflow) |

## 📊 Package Stats

- **Version:** X.X.X
- **Status:** {Development/Production/Stable}
- **Code Quality:** R CMD check status
- **Test Coverage:** XXX tests, XX% coverage
- **{Key Metric}:** {Value}

## 🏗️ Architecture at a Glance

```
{Visual representation of package structure}
{Adapt format based on package type}
```

## 🔍 What's Different About This Package?

{List 3-5 key differentiators or recent improvements}

✅ **{Feature 1}** - {Benefit}
✅ **{Feature 2}** - {Benefit}
✅ **{Feature 3}** - {Benefit}

---

**Last Updated:** {Date}
**Package Version:** X.X.X
**Maintainer:** {Name/Organization}
```

### 2. Getting-Started.md

Include:
- **Installation** (from GitHub, CRAN, or internal)
- **Basic usage examples** (adapted to package type)
- **Project structure** (directory layout with explanations)
- **Key files explained** (purpose of main files)
- **Understanding the flow** (how package works)
- **First steps after installation** (verification checklist)
- **Common issues** (troubleshooting)
- **Next steps** (links to deeper documentation)

### 3. Architecture-&-Design.md

Include:
- **Design philosophy** (principles guiding development)
- **Architectural overview** (layered diagram)
- **Data/process flow pipeline** (visual representation)
- **Module design** (why organized this way)
- **Design decisions & trade-offs** (key choices made)
- **Architectural benefits** (before/after metrics if refactored)
- **Design patterns** (patterns used and why)
- **Performance considerations** (current performance, optimization opportunities)
- **Refactoring metrics** (if applicable - code reduction, test growth)
- **Architectural evolution** (history of major changes)
- **Key takeaways** (lessons learned)

### 4. Module-Reference.md (or Function-Reference.md)

**For modular packages:**
- Group functions by module/file
- For each function:
  - Signature with parameter types
  - Parameters table
  - Return value description
  - Example usage
  - Notes/caveats
- Function dependency graph

**For data packages:**
- Dataset descriptions
- Column dictionaries
- Data sources and methodology
- Update frequency
- Example queries

**For analysis packages:**
- Statistical methods organized by category
- Mathematical formulas (if applicable)
- Algorithm explanations
- Interpretation guides

### 5. Testing-Guide.md

Include:
- **Test suite overview** (counts by file, coverage areas)
- **Running tests** (commands for different scenarios)
- **Test structure** (testthat format, organization)
- **Test coverage by module** (detailed breakdown)
- **Edge cases covered** (list of tested edge cases)
- **Writing new tests** (template and guidelines)
- **Debugging failed tests** (strategies)
- **Common test failures** (troubleshooting)
- **Test-driven development workflow**
- **Best practices** (do's and don'ts)

### 6. Validation-System.md (or Quality-Assurance.md)

**For packages with validation:**
- Why validation matters
- Validation strategy (fail-fast, boundaries)
- Validation points (where validation occurs)
- Error message design principles
- Validation test coverage
- Adding new validation rules

**For packages without explicit validation:**
- Rename to Quality-Assurance.md
- Code quality checks
- Linting and formatting
- Documentation standards
- Dependency management

### 7. Deployment.md

**For Shiny apps:**
- Prerequisites
- First-time setup (rsconnect, API keys)
- Deployment methods (command-line, RStudio UI, CI/CD)
- Configuration files
- Updating existing deployments
- Troubleshooting (common issues and solutions)
- Post-deployment tasks
- Deployment checklist
- Advanced configuration
- Rollback strategy
- Security considerations

**For CRAN packages:**
- CRAN submission process
- Checklist before submission
- Responding to CRAN feedback
- Version numbering

**For internal packages:**
- Installation from private repos
- Authentication setup
- Version pinning

**Omit this page** if package is not deployed (pure library).

### 8. Development-Workflow.md

Include:
- **Quick reference** (links to task guides)
- **Common development tasks** (step-by-step guides):
  - Adding new functionality
  - Modifying existing features
  - Adding validation/checks
  - Updating dependencies
- **Code style guidelines** (naming, formatting, documentation)
- **Git workflow** (branching, commits, PRs)
- **Release process** (versioning, tagging, publishing)

### 9. Dependencies-&-Risk.md

Include:
- **Dependency summary** (Imports, Suggests, versions)
- **Key dependency decisions** (why each dependency)
- **Security considerations** (data access, network, inputs)
- **Stability risks** (what could break and mitigations)
- **External factors** (environment, ecosystem)

### 10. Changelog-&-Maintenance.md (Optional)

Include:
- **Version history** (major releases and changes)
- **Known issues** (current bugs or limitations)
- **To-do list** (planned enhancements)
- **Future enhancements** (wishlist items)
- **Deprecation notices** (planned removals)

## Customization by Package Type

### Shiny App Packages:
- Emphasize UI/UX architecture
- Include server-side data flow
- Deployment is critical (full Deployment.md)
- Module Reference covers both server and UI functions

### Data Packages:
- Architecture focuses on data pipeline
- Module Reference becomes Dataset Reference
- Include data quality and validation
- Deployment covers data updates and versioning

### Analysis Packages:
- Architecture explains analytical pipeline
- Module Reference groups by statistical method
- Include methodology and theoretical background
- Validation covers input assumptions

### Utility Packages:
- Architecture shows function categories
- Module Reference organized by use case
- Emphasize performance and edge cases
- Examples show integration with other packages

## Output Format

### File Structure:
```
wiki/
├── Home.md
├── Getting-Started.md
├── Architecture-&-Design.md
├── Module-Reference.md  (or Function-Reference.md)
├── Testing-Guide.md
├── Validation-System.md  (or Quality-Assurance.md)
├── Deployment.md  (if applicable)
├── Development-Workflow.md
├── Dependencies-&-Risk.md
└── Changelog-&-Maintenance.md  (optional)
```

### Formatting Standards:
- Use proper markdown headers (# ## ###)
- Code blocks with language hints (```r, ```bash)
- Internal wiki links: `[Page Name](Page-Name)` (no .md extension)
- Tables for structured information
- Visual diagrams using text/ASCII art
- Collapsible sections for long content (if supported)

### Writing Style:
- Clear, technical but accessible
- Use "you" for instructions
- Active voice ("Create a function" not "A function should be created")
- Code examples for all concepts
- Bullet points for lists
- Tables for comparisons
- Emoji sparingly (only in Home.md for visual hierarchy)

## Validation Checklist

After generating wiki:
- [ ] All internal links work (wiki page to wiki page)
- [ ] Code examples are syntactically correct
- [ ] Directory structure matches actual package
- [ ] Function signatures match actual code
- [ ] Architecture diagrams are accurate
- [ ] Page names follow GitHub Wiki conventions (Title-Case-With-Hyphens)
- [ ] Navigation is clear (each page links to relevant others)
- [ ] Content is comprehensive but not overwhelming
- [ ] Examples are realistic and runnable
- [ ] Technical accuracy verified

## Example Invocation

"Create comprehensive GitHub Wiki documentation for cpiaapp, a Shiny dashboard package for visualizing CPIA governance indicators. The package has 6 utility modules (metadata, data, data_prep, plot, table, ui) with 19 helper functions, 134 passing tests, comprehensive input validation, and deploys to Posit Connect. Architecture follows layered design: UI → Server Orchestration → Helper Functions → Data Layer. Include all standard wiki pages with emphasis on the validation system and modular architecture."

---

**Related Prompts:**
- `create-readme.prompt.md` - For package overview
- `create-r-vignette.prompt.md` - For user tutorials
