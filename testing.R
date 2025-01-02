library(shiny)

ui <- fluidPage(
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
  actionButton("clearSiteData", "Clear Site Data"),
  tableOutput("myTable"),
  
  
  useShinyjs(),
  fileInput("fileUpload", "Upload Scada data .xlsx, .xls, or .csv file", accept = c(".xlsx", ".xls", ".csv")),
  verbatimTextOutput("fileInfo"),
  selectInput("addWTG", "Select WTGs", choices = NULL, multiple = TRUE),
  textInput("rating2", "Additional Rating Value", value = ""),
  actionButton("addRow2", "Add Row"),
  actionButton("clearSelectedData", "Clear Selected Data"),
  tableOutput("selectedData")
)

server <- function(input, output, session) {
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
      `Site Name` = input$siteName,
      `WTG Count` = input$wtgCount,
      Manufacturer = input$manufacturer,
      `WTG Rating` = input$WTGRating
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
  })
  output$myTable <- renderTable({
    SiteData$data
  })
  
  
  observeEvent(input$fileUpload, {
    if (!is.null(input$fileUpload)) {
      df <- read.csv(input$fileUpload$datapath)
      updateSelectInput(session, "addWTG", choices = unique(df$WTG))
      output$fileInfo <- renderPrint({
        paste("File uploaded from: ", input$fileUpload$datapath)
      })
    }
  })
  
  selectedData <- reactiveVal(data.frame())
  
  observeEvent(input$addRow2, {
    if (!is.null(input$addWTG)) {
      newRow <- data.frame(WTG = paste(input$addWTG, collapse = ","), Rating = input$rating2)
      selectedData(bind_rows(selectedData(), newRow))
      reset("addWTG")
      reset("rating2")
    }
  })
  # Clear Selected Data button behavior
  observeEvent(input$clearSelectedData, {
    selectedData(data.frame())
  })
  
  output$selectedData <- renderTable({
    selectedData()
  })
}

shinyApp(ui = ui, server = server)
