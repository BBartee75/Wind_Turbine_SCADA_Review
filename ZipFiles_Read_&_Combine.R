# Load required libraries
library(readr)
library(dplyr)
library(purrr)

prompts <- list(
  SiteName = "What is the Wind Farm Name?  -->  ",
  fileLoc = "Have you transferd you SCADA files, to your desired location? y/n  --> ",
  ZipFile = "Is you SCADA file a .zip file? y/n --> "
)
# Collect user inputs
user_inputs <- lapply(prompts, readline)

#---------------------------------------------------------------------------------------------------
# Set the directory path containing zip files
if(user_inputs$fileLoc == "n") {
  stop("Please download the ZipFile .zip file to your desired location")
} else {
  if (user_inputs$ZipFile == "y") {
    PCname1 <- file.choose()
    dir_path <- dirname(PCname1)
  } else {
    stop("Please download the ZipFile .zip file to your desired location")
  }
}
zip_directory <- dir_path

#---------------------------------------------------------------------------------------------------
# Function to read all CSV files from a single zip file
read_csvs_from_zip <- function(zip_path) {
  # Get list of files in the zip
  zip_contents <- unzip(zip_path, list = TRUE)
  
  # Filter for CSV files
  csv_files <- zip_contents$Name[grepl("\\.csv$", zip_contents$Name, ignore.case = TRUE)]
  
  if (length(csv_files) == 0) {
    message("No CSV files found in: ", basename(zip_path))
    return(NULL)
  }
  
  # Read each CSV file from the zip
  csv_data_list <- map(csv_files, function(csv_file) {
    tryCatch({
      # Create a temporary connection to read from zip
      temp_data <- read_csv(unz(zip_path, csv_file), show_col_types = FALSE)
      
      # Don't add metadata columns
      
      message("Successfully read: ", csv_file, " from ", basename(zip_path))
      return(temp_data)
      
    }, error = function(e) {
      warning("Error reading ", csv_file, " from ", basename(zip_path), ": ", e$message)
      return(NULL)
    })
  })
  
  # Remove NULL entries (failed reads)
  csv_data_list <- csv_data_list[!sapply(csv_data_list, is.null)]
  
  return(csv_data_list)
}

# Main execution
tryCatch({
  # Check if directory exists
  if (!dir.exists(zip_directory)) {
    stop("Directory does not exist: ", zip_directory)
  }
  
  # Get list of all zip files in the directory
  zip_files <- list.files(zip_directory, pattern = "\\.zip$", full.names = TRUE, ignore.case = TRUE)
  
  if (length(zip_files) == 0) {
    stop("No zip files found in the specified directory")
  }
  
  message("Found ", length(zip_files), " zip file(s)")
  
  # Read CSV files from all zip files
  all_csv_data <- map(zip_files, read_csvs_from_zip)
  
  # Flatten the nested list structure
  all_csv_data <- flatten(all_csv_data)
  
  # Remove any NULL entries
  all_csv_data <- all_csv_data[!sapply(all_csv_data, is.null)]
  
  if (length(all_csv_data) == 0) {
    stop("No CSV files were successfully read from any zip files")
  }
  
  # Combine all data frames
  # Using bind_rows which handles different column structures gracefully
  combined_data <- bind_rows(all_csv_data)
  
  # Display summary information
  message("\n====== ZIP FILE DATA SUMMARY ======")
  message("Source of zip files: ", PCname1)
  message("Total CSV files processed: ", length(all_csv_data))
  message("Combined data frame dimensions: ", nrow(combined_data), " rows × ", ncol(combined_data), " columns")
  
  # Display first few rows
  message("\nFirst 6 rows of combined data:")
  print(head(combined_data))
  
}, error = function(e) {
  message("Error in main execution: ", e$message)
})

#---------------------------------------------------------------------------------------------------
csv.data <- data.frame(combined_data)

#colnames c("WTG", "TimeStamp10Min", "RealPower", "WindSpeed")

colCheck <- readline(
  "Using the above Data Frame print out please number the columns in this order:
                     1 = 'WTG', 2 = 'TimeStamp10Min', 3 = 'RealPower', 4 = 'WindSpeed' ")
colOrder <- as.numeric(unlist(strsplit(colCheck, ",")))

# Rename columns by position to standardized names == c("WTG", "TimeStamp10Min", "RealPower", "WindSpeed")
csv.data <- data.table::setnames(csv.data, 
                                 c(names(csv.data)[colOrder[1]],
                                   names(csv.data)[colOrder[2]],
                                   names(csv.data)[colOrder[3]],
                                   names(csv.data)[colOrder[4]]
                                   ),
                     c("WTG", "TimeStamp10Min", "RealPower", "WindSpeed")
)
csv.data[is.na(csv.data)] <- 0

#---------------------------------------------------------------------------------------------------
# Date Column coversion
# Check current class
current_class <- class(csv.data$TimeStamp10Min)

if (!inherits(csv.data$TimeStamp10Min, c("POSIXct", "POSIXt"))) {
  tryCatch({
    message("\nConverting your date column now...")
    
    # Show progress bar
    pb <- txtProgressBar(min = 0, max = 100, style = 3)
    setTxtProgressBar(pb, 50)
    
    csv.data$TimeStamp10Min <- anytime::anytime(csv.data$TimeStamp10Min)
    
    setTxtProgressBar(pb, 100)
    close(pb)
    
    message(paste("TimeStamp10Min converted from", current_class[1], "to POSIXct"))
  }, error = function(e) {
    warning(paste("Failed to convert TimeStamp10Min:", e$message))
  })
} else {
  message("TimeStamp10Min is already in correct POSIXct/POSIXt format")
}

#---------------------------------------------------------------------------------------------------
# Write CSV
write.csv(csv.data, paste0("./Downloaded_Data/", user_inputs$SiteName , ".csv"))
message(paste("csv.data data saved to:", paste0("./Downloaded_Data/",user_inputs$SiteName , ".csv") ))
