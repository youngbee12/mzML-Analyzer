# deploy.R
# Script to deploy the Shiny app to shinyapps.io

message("Starting deployment setup...")

# Function to safely install CRAN packages
install_if_missing <- function(package) {
  if (!requireNamespace(package, quietly = TRUE)) {
    message(sprintf("Installing package: %s", package))
    install.packages(package, dependencies = TRUE)
  }
}

# Function to safely install Bioconductor packages
install_bioc_if_missing <- function(package) {
  if (!requireNamespace(package, quietly = TRUE)) {
    message(sprintf("Installing Bioconductor package: %s", package))
    if (!requireNamespace("BiocManager", quietly = TRUE)) {
      install.packages("BiocManager")
    }
    BiocManager::install(package, update = FALSE)
  }
}

# Required CRAN packages
cran_packages <- c(
  "rsconnect",
  "shiny",
  "shinydashboard",
  "DT",
  "plotly",
  "optparse",
  "jsonlite",
  "renv"
)

# Required Bioconductor packages
bioc_packages <- c(
  "MSnbase",
  "xcms",
  "mzR"  # 添加mzR作为依赖
)

# Install all required packages
message("Installing required packages...")
tryCatch({
  # Install CRAN packages
  sapply(cran_packages, install_if_missing)
  
  # Install Bioconductor packages
  sapply(bioc_packages, install_bioc_if_missing)
  
}, error = function(e) {
  message("Error installing packages: ", e$message)
  quit(status = 1)
})

# Load rsconnect
library(rsconnect)

# Set account info
message("Configuring shinyapps.io account...")
tryCatch({
  rsconnect::setAccountInfo(
    name = 'yangzhicheng',
    token = '2466E6D8F0A9825E6E47ADB05EF47415',
    secret = 'alVhfaH2fj3CdxemcdPUVG5onCTTyzfKdoGngaZz'
  )
}, error = function(e) {
  message("Error setting account info: ", e$message)
  quit(status = 1)
})

# Function to check if all required files exist
check_files <- function() {
  required_files <- c("app.R", "mzml_analyzer.R", "help.md")
  missing_files <- required_files[!file.exists(required_files)]
  
  if (length(missing_files) > 0) {
    stop("Missing required files: ", paste(missing_files, collapse = ", "))
  }
  return(TRUE)
}

# Function to deploy the application
deploy_app <- function() {
  message("Deploying application to shinyapps.io...")
  
  tryCatch({
    # Create manifest of all dependencies
    renv::snapshot(prompt = FALSE)
    
    # Deploy the application with all dependencies
    deployApp(
      appDir = ".",
      appName = "mzml-analyzer",
      appTitle = "mzML Analyzer",
      appFiles = c(
        "app.R",
        "mzml_analyzer.R",
        "help.md",
        "renv.lock"  # Include dependency manifest
      ),
      launch.browser = TRUE,
      forceUpdate = TRUE  # Force update to ensure all changes are applied
    )
    
    message("Application deployed successfully!")
    message("Your app is available at: https://yangzhicheng.shinyapps.io/mzml-analyzer/")
    
  }, error = function(e) {
    message("Error deploying application: ", e$message)
    message("Detailed error information:")
    print(e)
    stop("Deployment failed")
  })
}

# Main execution
message("Starting deployment process...")

# Run checks
tryCatch({
  message("Checking required files...")
  check_files()
  
  message("Installing and checking required packages...")
  
  # Deploy the app
  deploy_app()
  
}, error = function(e) {
  message("Error: ", e$message)
  message("\nDeployment process failed. Please fix the errors and try again.")
  quit(status = 1)
}) 