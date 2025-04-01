# run.R
# Launcher script for mzML Analyzer

# Set working directory to script location
setwd(dirname(sys.frame(1)$ofile))

# Load required packages
required_packages <- c(
  "shiny",
  "shinydashboard",
  "MSnbase",
  "xcms",
  "DT",
  "plotly"
)

# Install missing packages
missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]
if (length(missing_packages) > 0) {
  message("Installing missing packages...")
  
  # Install Bioconductor packages
  if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
  
  bioc_packages <- c("MSnbase", "xcms")
  missing_bioc <- intersect(missing_packages, bioc_packages)
  if (length(missing_bioc) > 0)
    BiocManager::install(missing_bioc)
  
  # Install CRAN packages
  missing_cran <- setdiff(missing_packages, bioc_packages)
  if (length(missing_cran) > 0)
    install.packages(missing_cran)
}

# Load packages
sapply(required_packages, library, character.only = TRUE)

# Run the application
message("Starting mzML Analyzer...")
shiny::runApp("app.R", launch.browser = TRUE) 