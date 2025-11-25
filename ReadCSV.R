# Load required libraries
library(readr)
library(dplyr)
library(purrr)

prompts <- list(
  SiteName = "What is the Wind Farm Name?  -->  ",
  fileLoc = "Have you transferd you SCADA files, to your desired location? y/n  --> ",
  csvFile = "Is you SCADA file a .csv file? y/n --> "
)
# Collect user inputs
user_inputs <- lapply(prompts, readline)

#---------------------------------------------------------------------------------------------------
# Set the directory path containing zip files
if(user_inputs$fileLoc == "n") {
  stop("Please download the csvFile .csv file to your desired location")
} else {
  if (user_inputs$csvFile == "y") {
    PCname1 <- file.choose()
    dir_path <- dirname(PCname1)
    
    file_name <- basename(PCname1)
    # Optional: print the information
    message("Selected file: ", file_name)
    message("File location: ", dir_path)
    dir_path <- paste0(dir_path, "/", file_name)
  } else {
    stop("Please download the csvFile .csv file to your desired location")
  }
}


#---------------------------------------------------------------------------------------------------
# Function to read all CSV files from a single zip file
read_csvs <- read.csv(dir_path) 
  
  
  



#---------------------------------------------------------------------------------------------------
csv.data <- data.frame(read_csvs)
print(head(csv.data))

colCheck <- readline(
  "\nLook at the data table above. Find the column numbers that best match these 4 items:
    1 = 'WTG' (turbine name)
    2 = 'TimeStamp10Min' (date and time)
    3 = 'RealPower' (power output)
    4 = 'WindSpeed' (wind speed)
    Enter the 4 column numbers in order, separated by commas (example: 2,5,7,9): ")
colOrder <- as.numeric(unlist(strsplit(colCheck, ",")))

# Rename columns by position to standardized names
csv.data <- data.table::setnames(csv.data, 
                                 c(names(csv.data)[colOrder[1]],
                                   names(csv.data)[colOrder[2]],
                                   names(csv.data)[colOrder[3]],
                                   names(csv.data)[colOrder[4]]),
                                 c("WTG", "TimeStamp10Min", "RealPower", "WindSpeed"))

csv.data[is.na(csv.data)] <- 0

message("\nPlease check your SCADA data. Make sure your columns are in this order:
    1 = 'WTG' (turbine name)
    2 = 'TimeStamp10Min' (date and time)
    3 = 'RealPower' (power output)
    4 = 'WindSpeed' (wind speed)\n\n")

print(head(csv.data))

dataCheck <- readline("Is the above data correct, and the columns are in the correct order? (y/n): ")

if(tolower(dataCheck) == "n"){
  csv.data <- data.frame(read_csvs)
  print(head(csv.data))
  
  colCheck <- readline(
    "\nLook at the data table above. Find the column numbers that best match these 4 items:
    1 = 'WTG' (turbine name)
    2 = 'TimeStamp10Min' (date and time)
    3 = 'RealPower' (power output)
    4 = 'WindSpeed' (wind speed)
    Enter the 4 column numbers in order, separated by commas (example: 2,5,7,9): ")
  colOrder <- as.numeric(unlist(strsplit(colCheck, ",")))
  
  # Rename columns by position to standardized names
  csv.data <- data.table::setnames(csv.data, 
                                   c(names(csv.data)[colOrder[1]],
                                     names(csv.data)[colOrder[2]],
                                     names(csv.data)[colOrder[3]],
                                     names(csv.data)[colOrder[4]]),
                                   c("WTG", "TimeStamp10Min", "RealPower", "WindSpeed"))
  
  csv.data[is.na(csv.data)] <- 0
  
  cat("\nPlease check your SCADA data. Make sure your columns are in this order:
    1 = 'WTG' (turbine name)
    2 = 'TimeStamp10Min' (date and time)
    3 = 'RealPower' (power output)
    4 = 'WindSpeed' (wind speed)\n\n")
  
  print(head(csv.data))
  
  readline("Press Enter to continue...")
}

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
