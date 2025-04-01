# mzML Analyzer

A Shiny application for analyzing mass spectrometry data in mzML format.

## Features

- Interactive Total Ion Chromatogram (TIC) visualization
- Automated peak detection and analysis
- Peak capacity calculation
- MS1 and MS2 spectra analysis
- Downloadable results in CSV format
- User-friendly web interface

## Requirements

- R version 4.0.0 or higher
- Required R packages:
  ```R
  install.packages(c("shiny", "shinydashboard", "DT", "plotly"))
  
  if (!requireNamespace("BiocManager", quietly = TRUE))
      install.packages("BiocManager")
  BiocManager::install(c("MSnbase", "xcms", "mzR"))
  ```

## Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/mzml-analyzer.git
cd mzml-analyzer
```

2. Install required packages (see Requirements section)

3. Run the application:
```R
shiny::runApp("src")
```

## Project Structure

```
mzml-analyzer/
├── src/
│   ├── app.R           # Main Shiny application
│   ├── mzml_analyzer.R # Core analysis functions
│   └── help.md         # Help documentation
├── example/            # Example data files
└── README.md          # This file
```

## Usage

1. Launch the application
2. Upload your mzML file
3. Set analysis parameters:
   - Gradient Time (minutes)
   - Mass Accuracy (ppm)
   - Peak Width Range (seconds)
4. Click "Analyze" to start processing
5. View results and download data

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Authors

- Your Name
- Your Email

## Acknowledgments

- The R community
- Bioconductor project
- Contributors to the MSnbase and xcms packages 