# app.R
# Shiny application for mzML analysis

# Error handling for package loading
required_packages <- c(
  "shiny",
  "shinydashboard",
  "MSnbase",
  "xcms",
  "DT",
  "plotly",
  "mzR"
)

# Function to check package availability
check_packages <- function() {
  missing_packages <- character()
  for (package in required_packages) {
    if (!requireNamespace(package, quietly = TRUE)) {
      missing_packages <- c(missing_packages, package)
    }
  }
  return(missing_packages)
}

# Check for missing packages
missing_packages <- check_packages()
if (length(missing_packages) > 0) {
  stop("Missing required packages: ", paste(missing_packages, collapse = ", "))
}

# Load packages with error handling
for (package in required_packages) {
  tryCatch({
    library(package, character.only = TRUE)
  }, error = function(e) {
    stop("Error loading package ", package, ": ", e$message)
  })
}

# Source analysis functions
tryCatch({
  source("mzml_analyzer.R")
}, error = function(e) {
  stop("Error loading mzml_analyzer.R: ", e$message)
})

# Set maximum file size limit (effectively unlimited - 100GB)
options(shiny.maxRequestSize = 100000*1024^2)

# UI Definition
ui <- dashboardPage(
  dashboardHeader(title = "mzML Analyzer"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Analysis", tabName = "analysis", icon = icon("chart-line")),
      menuItem("Results", tabName = "results", icon = icon("table")),
      menuItem("Help", tabName = "help", icon = icon("question-circle"))
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .shiny-notification {
          position: fixed;
          top: 10%;
          left: 50%;
          transform: translateX(-50%);
        }
        .progress-text {
          margin-top: 10px;
          text-align: center;
          font-weight: bold;
        }
        .file-size-warning {
          color: #856404;
          background-color: #fff3cd;
          border: 1px solid #ffeeba;
          padding: 10px;
          margin: 10px 0;
          border-radius: 4px;
        }
      "))
    ),
    tabItems(
      # Analysis Tab
      tabItem(tabName = "analysis",
        fluidRow(
          box(
            title = "Input Parameters",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            fileInput("file", "Select mzML file",
                     accept = c(".mzML", ".mzml")),
            tags$div(
              class = "file-size-warning",
              "Note: Processing time depends on file size. For very large files, please ensure sufficient system memory is available."
            ),
            numericInput("gradient_time", "Gradient Time (minutes)",
                        value = 60, min = 1),
            numericInput("ppm", "Mass Accuracy (ppm)",
                        value = 25, min = 1),
            textInput("peakwidth", "Peak Width Range (seconds, format: min,max)",
                        value = "5,30"),
            actionButton("analyze", "Analyze", 
                        class = "btn-primary",
                        icon = icon("play"))
          ),
          box(
            title = "Analysis Status",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            verbatimTextOutput("status"),
            tags$div(
              class = "progress-text",
              textOutput("progress_text")
            )
          )
        ),
        fluidRow(
          box(
            title = "TIC Chromatogram",
            status = "success",
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("tic_plot", height = "400px")
          )
        )
      ),
      
      # Results Tab
      tabItem(tabName = "results",
        fluidRow(
          box(
            title = "Analysis Results",
            status = "success",
            solidHeader = TRUE,
            width = 12,
            DTOutput("results_table")
          )
        ),
        fluidRow(
          box(
            title = "Peak Information",
            status = "warning",
            solidHeader = TRUE,
            width = 12,
            DTOutput("peaks_table")
          )
        ),
        fluidRow(
          box(
            title = "Download Results",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            downloadButton("download", "Download Results")
          )
        )
      ),
      
      # Help Tab
      tabItem(tabName = "help",
        fluidRow(
          box(
            title = "Help Information",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            includeMarkdown("help.md")
          )
        )
      )
    )
  )
)

# Server Definition
server <- function(input, output, session) {
  # Reactive values to store results
  values <- reactiveValues(
    results = NULL,
    peaks_df = NULL,
    tic_data = NULL,
    error = NULL,
    progress_message = NULL
  )
  
  # File size check
  observe({
    req(input$file)
    file_size_mb <- file.info(input$file$datapath)$size / (1024^2)
    if (file_size_mb > 1000) {  # Warning for files over 1GB
      showNotification(
        "Large file detected. Processing may take several minutes.",
        type = "warning",
        duration = NULL
      )
    }
  })
  
  # Analysis function
  observeEvent(input$analyze, {
    req(input$file)
    
    # Reset states
    values$error <- NULL
    values$progress_message <- NULL
    
    # Show progress
    withProgress(message = 'Analysis in progress', value = 0, {
      
      tryCatch({
        # Update progress
        values$progress_message <- "Reading mzML file..."
        incProgress(0.2, detail = values$progress_message)
        
        # Read mzML file
        raw_data <- readMSData(input$file$datapath, mode = "onDisk")
        
        # Extract TIC
        values$progress_message <- "Extracting chromatogram..."
        incProgress(0.4, detail = values$progress_message)
        values$tic_data <- chromatogram(raw_data)
        
        # Run analysis
        values$progress_message <- "Analyzing peaks..."
        incProgress(0.6, detail = values$progress_message)
        results <- analyze_mzml(
          input$file$datapath,
          input$gradient_time,
          input$ppm,
          input$peakwidth
        )
        
        # Store results
        values$progress_message <- "Processing results..."
        incProgress(0.8, detail = values$progress_message)
        values$results <- results
        values$peaks_df <- results$peaks_df
        
        # Complete
        values$progress_message <- "Analysis complete"
        incProgress(1, detail = values$progress_message)
        
      }, error = function(e) {
        values$error <- paste("Error during analysis:", e$message)
        values$progress_message <- "Analysis failed"
        showNotification(
          values$error,
          type = "error",
          duration = NULL
        )
      })
    })
  })
  
  # Progress text output
  output$progress_text <- renderText({
    values$progress_message
  })
  
  # Status output
  output$status <- renderText({
    if (!is.null(values$error)) {
      return(values$error)
    }
    if (!is.null(values$results)) {
      return("Analysis completed successfully!")
    }
    return("Ready for analysis")
  })
  
  # TIC Plot
  output$tic_plot <- renderPlotly({
    req(values$tic_data)
    
    # Convert chromatogram data to data frame
    tic_df <- data.frame(
      time = rtime(values$tic_data[[1]]),
      intensity = intensity(values$tic_data[[1]])
    )
    
    plot_ly(data = tic_df,
            x = ~time, 
            y = ~intensity,
            type = "scatter", 
            mode = "lines",
            name = "TIC") %>%
      layout(title = "Total Ion Chromatogram",
             xaxis = list(title = "Retention Time (minutes)"),
             yaxis = list(title = "Intensity"))
  })
  
  # Results Table
  output$results_table <- renderDT({
    req(values$results)
    
    data.frame(
      Metric = c("File Name", "MS1 Spectra", "MS2 Spectra", 
                 "Detected Peaks", "Average FWHM (min)", 
                 "Gradient Time (min)", "Peak Capacity"),
      Value = c(values$results$file_name,
               values$results$ms1_count,
               values$results$ms2_count,
               values$results$peak_count,
               round(values$results$avg_FWHM_min, 2),
               values$results$gradient_time,
               round(values$results$peak_capacity))
    )
  })
  
  # Peaks Table
  output$peaks_table <- renderDT({
    req(values$peaks_df)
    values$peaks_df
  })
  
  # Download Handler
  output$download <- downloadHandler(
    filename = function() {
      paste0("mzml_analysis_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      write.csv(values$peaks_df, file, row.names = FALSE)
    }
  )
}

# Run the application with error handling
options(shiny.sanitize.errors = FALSE)
tryCatch({
  shinyApp(ui = ui, server = server)
}, error = function(e) {
  message("Fatal error starting application: ", e$message)
  print(e)
  stop(e)
}) 