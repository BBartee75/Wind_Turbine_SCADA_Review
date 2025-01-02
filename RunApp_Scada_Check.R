#' #################################################################################################
#' SCADA Check
#' 
#' Author: Bently Bartee
#' Date: 2024-01-26
#' 
#' How to use this file:
#'  1. Format and upload your SCADA Check data file to folder: 'SCADA_File_Downloads'
#'      a. The app below will ask and give an example for the input file and formatting.
#'      b. Refer to file 'ScadaCheckSample.csv' for a template with proper formatting.
#'    
#'  2. Run the 3 lines of code below
#'      a. A R-Shiny app will open in your default web browser.
#'      b. Best to use Chrome or Edge.
#' 
#' #################################################################################################


# Run in Order
# 1
setwd(getwd())
# 2 - A R-Shiny app will open in your default web browser.
runApp("./Scada_Check_ShinyApp.R")
