# mzml_analyzer.R
# Author: Your Name
# Description: Tool for analyzing mzML files to calculate peak capacity, FWHM, 
#              and count MS1/MS2 spectra

# Load required libraries
suppressPackageStartupMessages({
  library(MSnbase)
  library(xcms)
})

# Function to analyze mzML file
analyze_mzml <- function(file_path, gradient_time, ppm, peakwidth) {
  # Input validation
  if (is.null(file_path) || !file.exists(file_path)) {
    stop("Invalid or missing mzML file path")
  }
  
  if (!is.numeric(gradient_time) || gradient_time <= 0) {
    stop("Gradient time must be a positive number")
  }
  
  if (!is.numeric(ppm) || ppm <= 0) {
    stop("Mass accuracy (ppm) must be a positive number")
  }
  
  if (!grepl("^\\d+,\\d+$", peakwidth)) {
    stop("Peak width must be in format 'min,max' (e.g., '5,30')")
  }
  
  # Read mzML file
  raw_data <- readMSData(file_path, mode = "onDisk")
  
  # Count MS1 and MS2 spectra
  ms_levels <- msLevel(raw_data)
  ms1_count <- sum(ms_levels == 1)
  ms2_count <- sum(ms_levels == 2)
  
  # Extract TIC and detect peaks
  tic_chrom <- chromatogram(raw_data)
  
  # Parse peakwidth range
  pw_range <- as.numeric(strsplit(peakwidth, ",")[[1]])
  
  # Peak detection using centWave
  cwp <- CentWaveParam(ppm = ppm, peakwidth = pw_range)
  xdata <- findChromPeaks(raw_data, param = cwp)
  peaks_df <- as.data.frame(chromPeaks(xdata))
  
  # Calculate FWHM for each peak
  peaks_df$FWHM_sec <- 2.355 * ((peaks_df$rtmax - peaks_df$rtmin) / 4)
  peaks_df$FWHM_min <- peaks_df$FWHM_sec / 60
  
  # Calculate average FWHM and peak capacity
  avg_FWHM <- mean(peaks_df$FWHM_min, na.rm = TRUE)
  peak_capacity <- 1 + (gradient_time / avg_FWHM)
  
  # Prepare results
  results <- list(
    file_name = basename(file_path),
    ms1_count = ms1_count,
    ms2_count = ms2_count,
    peak_count = nrow(peaks_df),
    avg_FWHM_min = avg_FWHM,
    peak_capacity = peak_capacity,
    gradient_time = gradient_time,
    peaks_df = peaks_df,
    tic_data = tic_chrom
  )
  
  return(results)
} 