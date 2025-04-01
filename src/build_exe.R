# build_exe.R
# Script to create executable from Shiny app

# Install required packages if not present
if (!requireNamespace("electron", quietly = TRUE))
  install.packages("electron")
if (!requireNamespace("jsonlite", quietly = TRUE))
  install.packages("jsonlite")

library(electron)

# Configure the application
setup_config <- list(
  name = "mzML Analyzer",
  main = "app.R",
  version = "1.0.0",
  description = "Tool for analyzing mzML mass spectrometry data files",
  author = "Your Name",
  dependencies = c(
    "shiny",
    "shinydashboard",
    "MSnbase",
    "xcms",
    "DT",
    "plotly"
  )
)

# Create the executable
message("Creating executable...")
tryCatch({
  # Write configuration
  jsonlite::write_json(setup_config, "electron-config.json")
  
  # Build the executable
  electron::build_app(
    appDir = ".",
    electronTemplate = "default",
    config = "electron-config.json",
    outputDir = "../dist"
  )
  
  message("Executable created successfully in the 'dist' directory!")
  
}, error = function(e) {
  message("Error creating executable: ", e$message)
}) 