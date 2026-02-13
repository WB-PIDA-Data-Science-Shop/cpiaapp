# Deployment

Guide to deploying the cpiaapp Shiny dashboard to Posit Connect (formerly RStudio Connect).

## Prerequisites

1. **Access to Posit Connect server**
   - URL: `https://your-connect-server.com` (e.g., `https://w0lxdrconn01.worldbank.org`)
   - User account with publishing permissions
   - API key (generated from Posit Connect user settings)

2. **R package: rsconnect**
```r
install.packages("rsconnect")
```

3. **All dependencies installed locally**
```r
# Check dependencies
devtools::check()  # Should pass with 0 errors
```

4. **cpiaetl package available on server**
   - Ensure cpiaetl is installed on Posit Connect
   - Or configure private package repository

## First-Time Setup

### Step 1: Configure rsconnect Account

```r
library(rsconnect)

# Set up connection to Posit Connect
rsconnect::connectApiUser(
  account = "your_username",          # Your Posit Connect username
  server = "w0lxdrconn01.worldbank.org",  # Your Posit Connect server URL
  apiKey = "YOUR_API_KEY_HERE"        # API key from Posit Connect settings
)
```

### Step 2: Generate API Key

1. Log into Posit Connect web interface
2. Click your username (top right) → API Keys
3. Click "New API Key"
4. Give it a name (e.g., "cpiaapp deployment")
5. Copy the key (you won't see it again!)
6. Use this key in `connectApiUser()` above

### Step 3: Verify Connection

```r
# List your existing deployments
rsconnect::deployments()

# Should show empty list on first run, or existing apps if you've deployed before
```

## Deployment Methods

### Method 1: Command-Line Deployment (Recommended)

```r
# From package root directory
rsconnect::deployApp(
  appDir = getwd(),                    # Current directory
  appPrimaryDoc = "app.R",             # Entry point file
  appTitle = "CPIA Governance Dashboard",
  server = "w0lxdrconn01.worldbank.org",
  account = "your_username",
  forceUpdate = TRUE                   # Force update existing deployment
)
```

**Expected Output:**
```
── Preparing for deployment ─────────────────────────
✔ Bundling 47 files: R/, inst/, man/, DESCRIPTION, NAMESPACE, app.R, ...
✔ Capturing R dependencies with renv
✔ Checking package installation
✔ Uploading bundle (2.3 MB)
✔ Deploying to server
✔ Deployment successful

https://w0lxdrconn01.worldbank.org/content/12345/
```

### Method 2: RStudio UI Deployment

1. Open `app.R` in RStudio
2. Click "Publish" button (blue icon in top right of editor)
3. Select "Publish Application"
4. Choose Posit Connect as destination
5. Select files to include (default: all necessary files)
6. Click "Publish"

### Method 3: Scripted Deployment for CI/CD

```r
# deploy.R - Script for automated deployment

# Load configuration from environment or file
server <- Sys.getenv("CONNECT_SERVER", "w0lxdrconn01.worldbank.org")
account <- Sys.getenv("CONNECT_ACCOUNT")
api_key <- Sys.getenv("CONNECT_API_KEY")

# Configure rsconnect
rsconnect::setAccountInfo(
  name = account,
  server = server,
  apiKey = api_key
)

# Deploy
rsconnect::deployApp(
  appDir = ".",
  appPrimaryDoc = "app.R",
  appTitle = "CPIA Dashboard",
  server = server,
  account = account,
  forceUpdate = TRUE,
  launch.browser = FALSE  # Don't open browser in CI
)

cat("Deployment successful!\n")
```

**Usage:**
```bash
# Set environment variables
export CONNECT_SERVER="w0lxdrconn01.worldbank.org"
export CONNECT_ACCOUNT="your_username"
export CONNECT_API_KEY="your_api_key"

# Run deployment script
Rscript deploy.R
```

## Deployment Configuration

### app.R - Entry Point

The package includes `app.R` as the deployment entry point:

```r
# app.R
library(cpiaapp)
run_cpiaapp()
```

**Why this works:**
- Posit Connect looks for `app.R` or `server.R` + `ui.R`
- `app.R` loads the package and launches the app
- All package code is bundled and deployed

### Manifest File (.rsconnect/)

After first deployment, `.rsconnect/` directory is created with deployment metadata:

```
.rsconnect/
  └── rsconnect/
      └── w0lxdrconn01.worldbank.org/
          └── your_username/
              └── cpia-dashboard.dcf
```

**Don't delete this!** It tracks deployment history and enables updates.

**Git:** Add `.rsconnect/` to `.gitignore` (deployment-specific, not code)

## Updating an Existing Deployment

### Update with Same Settings

```r
# From package root
rsconnect::deployApp(
  appDir = getwd(),
  forceUpdate = TRUE
)
```

rsconnect remembers previous deployment settings from `.rsconnect/` directory.

### Update with New Settings

```r
# Change app title or other settings
rsconnect::deployApp(
  appDir = getwd(),
  appTitle = "CPIA Dashboard v2",  # New title
  forceUpdate = TRUE
)
```

## Troubleshooting

### Issue 1: Missing Dependencies

**Error:**
```
Error: there is no package called 'cpiaetl'
```

**Cause:** cpiaetl not available on Posit Connect server.

**Solution:**
```r
# Option 1: Install cpiaetl on Posit Connect server
# Contact server admin to install cpiaetl

# Option 2: Bundle cpiaetl with deployment (if allowed)
# Add cpiaetl to Imports in DESCRIPTION
# Deploy with bundled package
```

### Issue 2: Missing app.R

**Error:**
```
Error: appPrimaryDoc must exist
```

**Cause:** Deploying from wrong directory or app.R doesn't exist.

**Solution:**
```r
# Ensure you're in package root directory
getwd()  # Should show .../cpiaapp

# Check for app.R
file.exists("app.R")  # Should be TRUE

# If missing, create it:
writeLines(c(
  "library(cpiaapp)",
  "run_cpiaapp()"
), "app.R")
```

### Issue 3: Package Not Installed

**Error:**
```
Error: there is no package called 'cpiaapp'
```

**Cause:** Package not installed before deployment.

**Solution:**
```r
# Install package locally first
devtools::install()

# Then deploy
rsconnect::deployApp(...)
```

### Issue 4: Account Not Found

**Error:**
```
Error: Can't find any accounts with `server` = "w0lxdrconn01.worldbank.org"
```

**Cause:** rsconnect not configured with server credentials.

**Solution:**
```r
# Re-run account setup
rsconnect::connectApiUser(
  account = "your_username",
  server = "w0lxdrconn01.worldbank.org",
  apiKey = "your_api_key"
)

# Verify
rsconnect::accounts()
# Should show your account
```

### Issue 5: Permission Denied

**Error:**
```
Error: You do not have permission to deploy to this server
```

**Cause:** User account lacks publishing permissions.

**Solution:**
- Contact Posit Connect administrator
- Request "Publisher" role for your account
- Or deploy to different server/space where you have permissions

### Issue 6: Large Deployment Size

**Warning:**
```
Warning: Deployment bundle is 50 MB (maximum 100 MB)
```

**Cause:** Large data files or unnecessary files included.

**Solution:**
```r
# Create .rscignore file to exclude files
# .rscignore (similar to .gitignore)
tests/
vignettes/
*.Rproj
.git/
copilot_logs/
wiki/

# Deploy with exclusions
rsconnect::deployApp(
  appDir = getwd(),
  appFileManifest = "manifest.json"  # rsconnect generates this
)
```

### Issue 7: Dependency Version Conflicts

**Error:**
```
Error: package 'dplyr' 1.1.0 is required but 1.0.0 is installed
```

**Cause:** Posit Connect has older package versions.

**Solution:**
```r
# Option 1: Ask admin to update packages on server

# Option 2: Relax version constraints in DESCRIPTION
# Change:
#   Imports: dplyr (>= 1.1.4)
# To:
#   Imports: dplyr (>= 1.0.0)

# Option 3: Use renv for reproducibility
renv::snapshot()  # Lock exact versions
# rsconnect will use renv.lock for deployment
```

## Post-Deployment Tasks

### 1. Test the Deployed App

```r
# Get deployment URL from console output
# Or find in Posit Connect web interface

# Test in browser:
# https://w0lxdrconn01.worldbank.org/content/12345/

# Verify:
# - App loads without errors
# - All 13 questions appear in dropdown
# - Plots render correctly
# - Tables export (CSV, Excel, PDF)
# - Dataset switching works (Standard ↔ African Integrity)
```

### 2. Configure Access Settings

In Posit Connect web interface:
1. Navigate to your app
2. Click "Settings" → "Access"
3. Choose access level:
   - **Private:** Only you can view
   - **Shared:** Specific users/groups
   - **Public:** Anyone with link

### 3. Set Up Schedules (Optional)

If app needs data refresh:
1. Click "Settings" → "Schedule"
2. Set refresh interval
3. Configure email notifications

### 4. Monitor Performance

1. Click "Metrics" tab in Posit Connect
2. View:
   - Active users
   - Resource usage (CPU, memory)
   - Error logs
3. Set up alerts for errors or high usage

## Deployment Checklist

Before deploying:

- [ ] All tests passing (`devtools::test()`)
- [ ] R CMD check clean (`devtools::check()`)
- [ ] Dependencies properly declared in DESCRIPTION
- [ ] app.R exists and works locally
- [ ] cpiaetl available on target server
- [ ] rsconnect account configured
- [ ] API key valid and permissions granted

After deploying:

- [ ] App loads successfully at deployment URL
- [ ] All functionality tested (plots, tables, export)
- [ ] Access settings configured appropriately
- [ ] Error monitoring enabled
- [ ] URL shared with stakeholders

## Advanced Configuration

### Custom Environment Variables

```r
# In app.R or run_cpiaapp.R
Sys.setenv(
  CPIA_DATA_SOURCE = "custom_path",
  CPIA_LOG_LEVEL = "INFO"
)

run_cpiaapp()
```

### R Version Specification

```r
# Specify R version in .Rprofile
options(
  repos = c(CRAN = "https://cran.rstudio.com/"),
  renv.config.r.version = "4.3.0"
)
```

### Custom Startup Script

```r
# .Rprofile - runs before app starts
message("Loading cpiaapp for Posit Connect...")
options(shiny.port = 3838)
```

## Rollback Strategy

If deployment fails or introduces issues:

```r
# Option 1: Re-deploy previous version
# Git checkout previous commit
git checkout abc123

# Deploy
rsconnect::deployApp(forceUpdate = TRUE)

# Option 2: Use Posit Connect rollback feature
# Web interface → Settings → Versions → Restore
```

## Security Considerations

1. **Never commit API keys** - Use environment variables or secure vaults
2. **Use HTTPS** - Ensure Posit Connect uses TLS/SSL
3. **Limit access** - Use appropriate access controls in Posit Connect
4. **Audit logs** - Review deployment logs for suspicious activity
5. **Update dependencies** - Keep packages up-to-date for security patches

---

**Next:** [Development Workflow](Development-Workflow) →
