# mzML Analyzer Help

## Overview
mzML Analyzer is a tool for analyzing mass spectrometry data in mzML format. It provides features for chromatogram visualization, peak detection, and basic statistical analysis of MS data.

## Input Parameters

### mzML File
- Select a valid mzML file using the file upload button
- The file should contain MS1 and optionally MS2 spectra
- File size limit: 2GB

### Gradient Time
- Enter the LC gradient time in minutes
- This is used for peak capacity calculations
- Typical values: 30-120 minutes
- Must be greater than 1 minute

### Mass Accuracy
- Specify the mass accuracy in parts per million (ppm)
- This affects peak detection sensitivity
- Recommended range: 10-50 ppm
- Lower values are more stringent

### Peak Width Range
- Enter the expected peak width range in seconds
- Format: minimum,maximum (e.g., "5,30")
- Affects peak detection algorithm
- Choose based on your chromatography conditions

## Analysis Process

1. File Upload
   - Select your mzML file
   - The application will validate the file format

2. Parameter Setting
   - Set analysis parameters as described above
   - Click "Analyze" to start processing

3. Results
   - Total Ion Chromatogram (TIC) will be displayed
   - Analysis metrics will be shown in the Results tab
   - Peak information will be available in a downloadable table

## Troubleshooting

### Common Issues

1. File Upload Fails
   - Check file format (must be .mzML)
   - Ensure file size is within limits
   - Verify file is not corrupted

2. Analysis Errors
   - Confirm parameters are within valid ranges
   - Check if file contains required scan types
   - Ensure sufficient memory is available

3. No Peaks Detected
   - Try adjusting mass accuracy (ppm)
   - Modify peak width range
   - Verify data quality in file

### Error Messages

- "Missing required packages": Install the indicated R packages
- "Error loading mzML file": Check file format and permissions
- "Invalid parameter value": Adjust input parameters to valid ranges

## Contact

For technical support or bug reports, please contact:
[Your Contact Information]

## References

1. MSnbase Documentation: [Link]
2. XCMS Documentation: [Link]
3. Mass Spectrometry Data Analysis Best Practices: [Link] 