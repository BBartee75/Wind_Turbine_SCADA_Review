# Suppress messages and warnings
suppressMessages({
  suppressWarnings({
    library(shiny)
    library(shinyWidgets)
    library(shinyjs)
    library(shinyalert)
    library(rmarkdown)
    library(zip)
    library(dplyr)
    library(lubridate)
    library(anytime)
    library(leaflet)
    library(tidyr)
  })
})

#-------------------------------------------------------------------------------------------------
#functions / variables needed:
samplecsv <- head(read.csv("./ScadaCheck.csv"), 5)

#------------------------------------------------------------------------------------------------- 

# Define UI
ui <- fluidPage(
  tags$script(HTML("
    window.addEventListener('beforeunload', function (e) {
        e.returnValue = 'Are you sure you want to leave?';
    });
 ")),
  # Title and image at the top
  fluidRow(
    column(8, tags$h1("SCADA Check Dashboard", style = "font-weight: bold;"), 
           tags$i(HTML("<p>&copy; UL Renewables Asset Advisory, USA</p>"))),
    column(4, div(style = "text-align: right;", img(src = "ULimage.PNG", height = "100px")))
  ),
 
 # Rest of the UI elements
 #-------------------------------------------------------------------------------------------------
 #Site Information Section
 HTML("<br><h3><u>Site Information</u></h3><br>"),
 #Page Disclaimer
 HTML("<b><small><span style='color: #CA0123;'>Disclaimer:</span><b/> If site has multiple manufacturers and/or numerous turbine rating types please add additional rows<br><br>"),
 HTML("<div>
 <p>Example: Site X has a total of 100 WTG.</p>
 <p>If 95 WTGs are GE 1.5 MW, and the other 5 are GE 1.62 MW for a total of 100 WTGs.</p>
 <p>You will need to fill out Site Information section twice.</p>
 <ul>
    <li>Enter: Site Name = Site X, Turbine Count = 95, Manufacture Type = GE 1.5 MW, Rating = 1500</li>
    <li>Click Add Row</li>
    <li>Enter: Site Name = Site X, Turbine Count = 5, Manufacture Type = GE 1.62 MW, Rating = 1620</li>
    <li>Click Add Row</li>
 </ul>
</div>"),
 HTML("</small><br>"),
 
 ## Site Information inputs
  textInput("siteName", "Enter Site Name", value = ""),
  # Enter WTG Counts
  tags$label(HTML("Enter Turbine Count <br> 
                  <small>(Enter the total number of WTGs.)</small>")),
  textInput("wtgCount", "", value = ""),
  # Enter Manufacturers
  tags$label(HTML("Enter Manufacturer Type <br> 
                  <small>(e.g., manufacturer type = GE 1.62 MW)</small>")),
  textInput("manufacturer", "", value = ""),
  # Enter the WTG kW rating
  tags$label(HTML("Enter WTG Rating <br> (e.g., 1.62mW = 1620 or 2.25mW = 2250) <br>
                  <small><i>kW = mW x 1000 or kW = 1.62 x 1000</i></small>")),
  textInput("WTGRating", "", value = ""),
  # Add new rows
  actionButton("addRow", "Add Row"),
  actionButton("clearSiteData", "Clear Site Information Data"),
  tableOutput("myTable"),
  
  #------------------------------------------------------------------------------------------------- 
  # External Data Section
  HTML("<style>
        hr {
            display: block;
            height: 1px;
            border: 0;
            border-top: 1.5px solid #bfbfbf;
            margin: 1em 0;
            padding: 0;
        }
        </style>
        <hr/>"),
  HTML("<h3><u>External Data Upload</u></h3><br>"),
  HTML("<h4 style='color: #CA0123;'>STOP! Before you load your .xls, .xlsx, or .csv data.</h4>
        Ensure it is formatted like the sample below:<br>
        <ul>
          <li>WTG = Use format used by customer for WTG naming</li>
            <ul>
              <li><small><i>The table below is an example, your customer naming format might be different</i></li></small>
            </ul>
          <li>TimeStamp10Min = Follow 'mm/dd/yyyy hh:mm' excel format (12/2/2023 9:50)</li>
          <li>RealPower = Enter in kW With two decimals places (418.98)</li>
          <li>WindSpeed = With two decimals places (11.66)</li>
        </ul>"),
  dataTableOutput("samplecsv"),  # UI element to display the sample data frame
  # Download Sample csv
  tags$label(HTML("<i style='color: #577E9E;'>NOTE: If needed, download a copy of SCADA_Check_InputFile</i>")),
  downloadButton("downloadData", "Download"),
 
  #-------------------------------------------------------------------------------------------------  
  #Upload External Data
  HTML("<style>
        hr {
            display: block;
            height: 1px;
            border: 0;
            border-top: 1.5px solid #bfbfbf;
            margin: 1em 0;
            padding: 0;
        }
        </style>
        <hr/>"),
  HTML("<h3><u>Upload External Data</u></h3>"),
  useShinyjs(),
  fileInput("fileUpload", "Upload Scada data .xlsx, .xls, or .csv file", accept = c(".xlsx", ".xls", ".csv")),
  verbatimTextOutput("fileInfo"),
  
  #------------------------------------------------------------------------------------------------- 
  #Additional WTG Ratings Section
  HTML("<style>
        hr {
            display: block;
            height: 1px;
            border: 0;
            border-top: 1.5px solid #bfbfbf;
            margin: 1em 0;
            padding: 0;
        }
        </style>
        <hr/>"),
  HTML("<h3><u>Additional WTG Ratings</u></h3>"),
  HTML("<b style='color: #577E9E;'><i>
      NOTE: Use Only if site has two or more manufacturers and/or rating types then fill out below; IF NOT SKIP.</i></b><br>"),
  HTML("<div>
      <p>Example: Site X has a total of 100 WTGs.</p>
      <p>If 95 WTGs are GE 1.5 MW, and the other 5 are GE 1.62 MW for a total of 100 WTGs.</p>
      <p>You will need to fill out the Additional WTG Ratings Section.</p>
      <ul>
        <li>Enter: Select One or Multiple turbines = Select all WTGs that have a different rating from the drop down.</li>
        <ul>
          <li><small>From the example above, Site X has 5 WTGs that are different from the site as a whole. Select those 5 WTGs.</small></li>
        </ul>
        <li>Enter: Additional Value = Input the Rating Value</li>
        <ul>
          <li><small>From the example above, Site X has 5 WTGs that are GE 1.62 MW: Enter 1620.</small></li>
        </ul>
        <li>Click Add Row</li>
        <ul>
          <li><small>Repeat Steps above if there are more WTGs to enter.</small></li>
        </ul>
      </ul>
  </div>"),
  selectInput("addWTG", "Select One or Multiple turbines", choices = NULL, multiple = TRUE),
  tags$label(HTML("Enter Additional WTG Rating <br> 
                  <small>(e.g., 1.62mW = 1620 or 2.25mW = 2250)</small>")),
  textInput("rating2", "Additional Value", value = ""),
  actionButton("addRow2", "Add Row"),
  actionButton("clearSelectedData", "Clear Addtional Rating Data"),
  tableOutput("selectedData"),
 
 #------------------------------------------------------------------------------------------------- 
 # Run Scada Check
  HTML("<style>
        hr {
            display: block;
            height: 1px;
            border: 0;
            border-top: 1.5px solid #bfbfbf;
            margin: 1em 0;
            padding: 0;
        }
        </style>
        <hr/>"),
 shinyWidgets::panel(
   fluidRow(
     column(12, align="center",
            actionButton("rmd", "Create SCADA Check Report")
     )
  )),
 uiOutput("SCADA_Check"),
 downloadButton("downloadSCADAReport", "Download SCADA Report"),
 HTML("<br><br>"),
 
 #--------------
 actionButton("close_app", "Close Application"),
 textOutput("status")
 
  #End of UI
)



#--------------------------------------------------------------------------------------------------- 
# Set max file upload size to 100MB
options(shiny.maxRequestSize = 100*1024^2)
#--------------------------------------------------------------------------------------------------- 



# Define SHINY SERVER logic
server <- shinyServer(function(input, output, session) {
  # ask if want to close web page
  observeEvent(input$closing, {
    session$onSessionEnded(function() {
      stopApp()
    })
  })
  
  #------------------------------------------------------------------------------------------------- 
  # Site Information
  SiteData <- reactiveValues(
    data = data.frame(
      `Site Name` = character(), 
      `WTG Count` = numeric(),
      Manufacturer = character(), 
      `WTG Rating` = numeric()
    )
  )
  observeEvent(input$addRow, {
    newEntry <- data.frame(
      `Site Name` = trimws(input$siteName),
      `WTG Count` = trimws(input$wtgCount),
      Manufacturer = trimws(input$manufacturer),
      `WTG Rating` = trimws(input$WTGRating)
    )
    SiteData$data <- rbind(isolate(SiteData$data), newEntry)
    updateTextInput(session, "siteName", value = "")
    updateTextInput(session, "wtgCount", value = "")
    updateTextInput(session, "manufacturer", value = "")
    updateTextInput(session, "WTGRating", value = "")
  })
  # Clear Site Data button behavior
  observeEvent(input$clearSiteData, {
    SiteData$data <- data.frame(
      `Site Name` = character(),
      `WTG Count` = numeric(),
      Manufacturer = character(),
      `WTG Rating` = numeric()
    )
    message("----- NOTE:: Site Information data has been cleared.")
  })
  output$myTable <- renderTable({
    SiteData$data
  })
  # Print site in the console
  observe({
    print(SiteData$data)
    message("----- NOTE:: SiteData has been processed")
  })
  
  # Render the sample data frame
  output$samplecsv <- renderDataTable({
    samplecsv
  }, options = list(
    dom = 't',  # This layout includes only the table without the other elements
    paging = FALSE,  # Disable pagination
    searching = FALSE,  # Disable search box
    info = FALSE  # Disable showing entries information
  ))
  
  #------------------------------------------------------------------------------------------------- 
  #External Data Upload Section******************************************
  observeEvent(input$fileUpload, {
    
    if (!is.null(input$fileUpload)) {
      # Get file extension
      file_ext <- tolower(tools::file_ext(input$fileUpload$datapath))
      
      tryCatch({
        # Read file based on extension
        df <- if (file_ext == "csv") {
          read.csv(input$fileUpload$datapath)
        } else if (file_ext %in% c("xls", "xlsx")) {
          readxl::read_excel(input$fileUpload$datapath)
        } else {
          # Instead of stopping, show warning message
          output$fileInfo <- renderText({
            paste("Please upload a CSV or Excel file. Current file type:", file_ext)
          })
          return(NULL)  # Exit the current if block
        }
        
        # If file read successfully, proceed with processing
        colnames(df) <- trimws(colnames(df), which = "right") #trim any whitespaces
        
        
        
        
        updateSelectInput(session, "addWTG", choices = unique(df$WTG))
        output$fileInfo <- renderText({
          paste("File successfully uploaded from:", input$fileUpload$datapath, "\n",
                "Total WTG count is:", length(unique(df$WTG)), "\n")
        })
      }, error = function(e) {
        # Handle any errors during file reading
        output$fileInfo <- renderText({
          paste("Error reading file. Please check if file is corrupted or try again.", 
                "Error details:", e$message)
        })
      })
    }
    
  })
  
  observe({
    req(input$fileUpload)  # Ensures SiteData$data exists
    print(input$fileUpload)  # Prints first few rows of the data
    message("----- NOTE:: SiteData has been loaded")
  })
  
  selectedData <- reactiveVal(data.frame())
  
  # Additional WTG Ratings
  observeEvent(input$addRow2, {
    if (!is.null(input$addWTG)) {
      newRow <- data.frame(WTG = paste(input$addWTG, collapse = ","), Rating = input$rating2)
      selectedData(bind_rows(selectedData(), newRow))
      reset("addWTG")
      reset("rating2")
    }
  })
  
  output$selectedData <- renderTable({
    data <- selectedData()
    message("----- NOTE:: Additional WTG Ratings data frame has been created.")
    return(data)  # Actually return the data to display
  })
  
  # Clear Selected Data button behavior
  observeEvent(input$clearSelectedData, {
    selectedData(data.frame())
    message("----- NOTE:: Additional WTG Ratings data has been cleared.")
  })
  
  
  
  
  #------------------------------------------------------------------------------------------------- 
  #test to make sure file upload is formatted correctly
  # observeEvent(input$run, {
  #   showModal(modalDialog(
  #     title = "Uploaded Scada file Format Confirmation",
  #     HTML("Have you formatted the .xls, .xlsx, or .csv file correctly? <br>
  #        WTG = Use customer naming, <br>
  #        TimeStamp10Min = Follow mm/dd/yyyy hh:mm excel format (12/2/2023 9:50) <br>
  #        RealPower = Enter in kW With two decimals places (418.98), <br>
  #        WindSpeed = With two decimals places (11.66)"),
  #     footer = tagList(
  #       modalButton("No"),
  #       actionButton("yes", "Yes")
  #     )
  #   ))
  # })
  
  #------------------------------------------------------------------------------------------------- 
  #download of sample data
  output$downloadData <- downloadHandler(
      filename = function() {
        "SCAD_Check_SampleData.csv"
      },
      content = function(file) {
        # Write the samplecsv content to the chosen file location
        write.csv(samplecsv, file, row.names = FALSE)
    }
  )
  
  #------------------------------------------------------------------------------------------------- 
  # Trigger SCADA.Check.Render when the "Run SCADA Check" button is clicked
  # Render the R Markdown file
  # Create reactive values to store processed data
  processedData <- reactiveValues(
    csv.data = NULL,
    wtgs = NULL,
    WTG.Models = NULL,
    SiteName = NULL,
    Total.Num.WTgs = NULL,
    ready = FALSE
  )
  
  # First observeEvent to process data
  observeEvent(input$rmd, {
    withProgress(message = 'Processing data...', value = 0, {
      Sys.sleep(1)  # Wait 1 second
      # Initial validation
      if (is.null(SiteData$data) || is.null(input$fileUpload)) {
        shinyalert::shinyalert(
          title = "Error",
          text = "<p>Please provide both site information and upload external data before creating the report.</p>
                    <ul>
                        <li>To input site information, please use the <u>Site Information Section</u>.</li>
                        <li>To upload external data, please use the <u>Upload External Data Section</u>.</li>
                    </ul>",
          type = "error",
          html = TRUE
        )
        return()
      }
      
      tryCatch({
        setProgress(0.2, detail = "Reading data file...")
        Sys.sleep(1)  
        
        # Read and process data file
        csv.data <- if(tools::file_ext(input$fileUpload$name) == "csv") {
          read.csv(input$fileUpload$datapath)
        } else {
          readxl::read_excel(input$fileUpload$datapath, sheet = 1)
        }
        
        setProgress(0.4, detail = "Converting data types...")
        Sys.sleep(1) 
        
        # Convert data types
        csv.data$TimeStamp10Min <- anytime::anytime(csv.data$TimeStamp10Min)
        csv.data$WindSpeed <- as.numeric(csv.data$WindSpeed)
        csv.data$RealPower <- as.numeric(csv.data$RealPower)
        max_count_index <- which.max(SiteData$data$WTG.Count)
        max_rating <- SiteData$data$WTG.Rating[max_count_index]
        csv.data$Rating <- as.numeric(max_rating)
        
        setProgress(0.6, detail = "Processing ratings...")
        Sys.sleep(1) 
        
        # Process additional ratings if they exist
        AddRating <- selectedData()
        
        if (!is.null(AddRating) && nrow(AddRating) > 0) {
          AddDF <- AddRating %>%
            separate_rows(WTG, sep = ",") %>%
            mutate(Rating2 = Rating) %>%
            select(WTG, Rating2)
          
          for (i in seq_len(nrow(AddDF))) {
            turbine <- AddDF$WTG[i]
            rate <- as.numeric(AddDF$Rating2[i])
            csv.data$Rating[csv.data$WTG == turbine] <- rate
          }
        } else {
          csv.data$Rating <- as.numeric(SiteData$data$WTG.Rating)
        }
        
        setProgress(0.8, detail = "Validating data...")
        Sys.sleep(1) 
        
        # Validate WTG counts
        wtgs <- unique(csv.data$WTG)
        if (sum(as.numeric(SiteData$data$WTG.Count)) != length(wtgs)) {
          shinyalert::shinyalert(
            title = "Error",
            text = "WTG Counts must match your input file unique list of WTG numbers.",
            type = "error"
          )
          return()
        }
        
        setProgress(0.9, detail = "Storing processed data...")
        Sys.sleep(1) 
        
        # Store all processed data in reactiveValues
        processedData$csv.data <- csv.data
        processedData$SiteName <- unique(SiteData$data$Site.Name)
        processedData$wtgs <- wtgs
        processedData$WTG.Models <- SiteData$data
        processedData$WTG.Models[[4]] <- as.numeric(as.character(processedData$WTG.Models[[4]]))
        names(processedData$WTG.Models)[4] <- "Rating (kW)"
        processedData$Total.Num.WTgs <- length(unique(csv.data$WTG))
        processedData$ready <- TRUE
        
        setProgress(1, detail = "Data processing complete")
        Sys.sleep(1) 
        
      }, error = function(e) {
        shinyalert::shinyalert(
          title = "Error",
          text = paste("An error occurred:", e$message),
          type = "error"
        )
        message("Error in data processing: ", e$message)
      })
    })
  })
  
  # Second observeEvent to render report when data is ready
  observeEvent(processedData$ready, {
    if(processedData$ready) {
      output$SCADA_Check <- renderUI({
        withProgress(message = 'Rendering R Markdown report...', value = 0, {
          # Call the onRender function to keep the progress bar visible during rendering
          shinyjs::runjs("shinyjs.showProgress()")#--------------------------------------------------------------------------------------
          
          # Update the progress value to 50% after data processing
          setProgress(0.5, detail = "Data processing.....")
          Sys.sleep(1)    # Wait 1 second
          setProgress(0.75, detail = "Data processing.....")
          Sys.sleep(.1)    # Wait 1 second
          
          csv.data = processedData$csv.data
          wtgs = processedData$wtgs
          WTG.Models = processedData$WTG.Models
          SiteName = processedData$SiteName
          Total.Num.WTgs = processedData$Total.Num.WTgs
          
          # Create output directory
          output_dir <- file.path(getwd(), "Report_Output", paste0(Sys.Date(), "_", SiteName))
          if (!dir.exists(output_dir)) {
            dir.create(output_dir, recursive = TRUE)
          }
          
          # Define filenames
          output_file <- paste0(Sys.Date(), "_", SiteName, "_SCADACheck.html")
          html_path <- file.path("www", output_file)
          zip_file <- file.path(output_dir, paste0(Sys.Date(), "_", SiteName, "_SCADACheck.zip"))
          
          # Render RMarkdown report
          rmarkdown::render("SCADACheck.Rmd", 
                            output_format = "html_document",
                            output_dir = "www",
                            output_file = output_file,
                            output_options = list(
                            html_dependency = htmltools::htmlDependency(
                                "shiny", "1.7.1", "/usr/local/lib/R/site-library/shiny/www/shared/shiny.js")
                            )
          )
          
          # Verify HTML was created successfully
          if (!file.exists(html_path)) {
            stop("HTML file not found after rendering:", html_path)
          }
          
          # Copy HTML to output directory
          file.copy(
            from = html_path,
            to = file.path(output_dir, output_file),
            overwrite = TRUE
          )
          
          setProgress(0.0, detail = "Preparing to create zip file...")
          Sys.sleep(1) 
          setProgress(0.5, detail = "Creating zip file...")
          Sys.sleep(1)  
          setProgress(0.75, detail = "Zipping files...")
          Sys.sleep(1) 
          
          # Create zip file - simplified zip call
          zip(zipfile = zip_file, 
              files = file.path(output_dir, output_file)
              )
          
          # Cleanup www folder files
          on.exit({
            # Get list of HTML files to delete
            html_files <- dir("www", pattern = "\\.html$", full.names = TRUE)
            # Delete each HTML file
            lapply(html_files, function(x) {
              tryCatch({
                unlink(x)
                message(paste("Deleted HTML file:", x))
              }, error = function(e) {
                message(paste("Warning: Could not delete HTML file:", x))
              })
            })
            message("Cleanup completed: HTML files removed from www folder")
          })
          
          # Add the resource path for the rendered HTML file
          shiny::addResourcePath("report", output_dir)
            
          # Update the progress value to 100% when rendering is complete
          setProgress(1, detail = "Rendering complete")
          Sys.sleep(1) 
          shinyjs::hide("html_output_progress")  # Hide the progress bar after rendering is complete
          
          # Include the rendered HTML using tags$iframe()
          tags$iframe(
            src = paste0("report/", output_file),
            style = "border:none; width:100%; height:1000px;"
          )
        
        })
      })
    }
  })
  #-------------------------------------------------------------------------------------------------
  # Download Report
  # paste0("Report_Output/", Sys.Date(),"_", isolate(SiteName()), "/", Sys.Date(), "_", isolate(SiteName()), "_SCADACheck.html")
  
  # Download Report
  SiteName <- reactive({
    unique(SiteData$data$Site.Name)
  })
  
  output$downloadSCADAReport <- downloadHandler(
    filename = function() {
      paste0(Sys.Date(), "_", isolate(SiteName()), "_SCADACheck.html")
    },
    content = function(file) {
      file.copy(paste0("Report_Output/", Sys.Date(),"_", isolate(SiteName()), "/", Sys.Date(), 
                       "_", isolate(SiteName()), "_SCADACheck.html"), 
                file)  # Copy the file to the download location
    }
  )
  
  #------------------------------------------------------------------------------------------------
  # Track whether we're shutting down
  rv <- reactiveValues(closing = FALSE)
  
  # Observe the close button
  observeEvent(input$close_app, {
    if (!rv$closing) {
      # Set closing flag
      rv$closing <- TRUE
      
      # Update status
      output$status <- renderText({
        "Closing application..."
      })
      
      # Close browser window
      js <- "window.close();"
      tags$script(js)
      
      # Stop the application
      stopApp()
    }
  })
  
  
  #--------------
  #End of Server
})

shinyApp(ui = ui, server = server)
