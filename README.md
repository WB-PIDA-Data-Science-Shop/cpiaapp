# cpiaapp

Interactive Shiny dashboard for visualizing and analyzing Country Policy and Institutional Assessment (CPIA) data.

## Overview

This package provides a Shiny dashboard application for CPIA data visualization and analysis.

## Installation

```r
# Install from GitHub (once repository is set up)
# devtools::install_github("WB-PIDA-Data-Science-Shop/cpiaapp")

# For development
devtools::load_all(".")
```

## Usage

```r
library(cpiaapp)

# Load your CPIA data

# Run the dashboard
```

## Dashboard Structure

The dashboard includes the following sections:

- **Home**: Welcome page with overview and dashboard structure
- **Overview**: High-level summary statistics and key metrics (to be developed)
- **Country Analysis**: Detailed country-level metrics and time-series (to be developed)
- **Regional Comparisons**: Cross-regional analysis (to be developed)
- **Trend Analysis**: Time-series diagnostics (to be developed)

## Design

The front-end design is adapted from the `govhrapp` package, featuring:

- Clean, modern interface using `bslib` for layout and theming
- Custom CSS styling with rounded cards and shadow effects
- Responsive navbar with icon-based navigation
- Source Sans Pro and Fira Sans fonts via Google Fonts
- Professional color scheme with World Bank branding

## Files Structure

```
cpiaapp/
├── R/
│   └── run_cpiaapp.R          # Main app function
├── inst/
│   ├── www/
│   │   ├── cpia_logo.png      # Dashboard logo
│   │   └── styles.css         # Custom CSS styles
│   └── markdown/
│       └── cpia_home.md       # Home page content
├── app.R                      # Deployment file
└── DESCRIPTION                # Package metadata
```

## Dependencies

- `shiny`: Web application framework
- `bslib`: Modern UI components and theming
- `thematic`: Automatic plot theming
- `cpiaetl`: CPIA data (suggested)

## Development

To add new dashboard modules:

1. Create UI and server functions for your module in `R/`
2. Add the module to the navbar in `run_cpiaapp.R`
3. Update documentation with `devtools::document()`

## License

MIT
