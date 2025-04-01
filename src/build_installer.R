# build_installer.R
# Script to create installers for Windows and Mac

# Install required packages if not present
if (!requireNamespace("remotes", quietly = TRUE))
  install.packages("remotes")

# Install RInno for Windows installer
if (!requireNamespace("RInno", quietly = TRUE))
  remotes::install_github("ficonsulting/RInno")

# Install mac.bundle for Mac app
if (!requireNamespace("mac.bundle", quietly = TRUE))
  remotes::install_github("nx10/mac.bundle")

# Detect OS
is_windows <- Sys.info()["sysname"] == "Windows"
is_mac <- Sys.info()["sysname"] == "Darwin"

if (is_windows) {
  library(RInno)
  
  # Configure the application
  create_app(
    app_name = "mzML Analyzer",
    app_dir = ".",
    dir_out = "../dist",
    pkgs = c(
      "shiny",
      "shinydashboard",
      "MSnbase",
      "xcms",
      "DT",
      "plotly"
    ),
    include_R = TRUE,    # Include R installation
    include_Rtools = FALSE,
    privilege = "high",
    default_dir = "%userprofile%/Desktop/mzML Analyzer",
    file_associations = c(".mzML", ".mzml")
  )
  
  # Compile the installer
  compile_iss()
  
} else if (is_mac) {
  library(mac.bundle)
  
  # Create Mac app bundle
  create_mac_bundle(
    app_name = "mzML Analyzer",
    app_dir = ".",
    out_dir = "../dist",
    r_libs = c(
      "shiny",
      "shinydashboard",
      "MSnbase",
      "xcms",
      "DT",
      "plotly"
    ),
    icon = NULL,  # You can add an icon file path here
    r_version = getRversion()
  )
  
} else {
  stop("Unsupported operating system")
}

message("Build process completed! Check the 'dist' directory for the output.") 