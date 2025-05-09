library(data.table)
library(dplyr)

"C:\\Users\\102957\\Documents\\R-Scripts\\Seiling II SCADA Data.xlsx"


read.All_CSVs <- function(filePath) {
  if (!require("data.table")) {
    install.packages("data.table")
    library(data.table)
  }
  # Input validation
  if (!dir.exists(filePath)) {
    stop("Directory path does not exist")
  }
  # Get CSV files
  csv_files <- dir(filePath, pattern = "*.csv$", full.names = TRUE)
  # Display files and wait for confirmation
  cat("Found CSV files:\n")
  cat(csv_files, sep = "\n")
  cat("\n\nPress Enter to continue (or ESC to stop): ")
  # Handle ESC key press
  response <- readline()
  if (tolower(substr(response, 1, 1)) == "esc") {
    return(NULL)
  }
  # Initialize data.table
  csv.data <- c()
  for (i in 1:NROW(csv_files)) {
    tryCatch({
      current_data <- fread(csv_files[i], quote = "")
      
      csv <- read.csv(csv_files[i])
      csv.data <- rbind(csv.data, csv)
      
    }, error = function(e) {
      warning(sprintf("Error processing %s: %s", filePath, e$message))
    })
      
  }
  return(csv.data)
}


csv.data <- data.frame(read.All_CSVs(filePath = "C:\\Users\\102957\\Documents\\R-Scripts"))

#colnames c("WTG", "TimeStamp10Min", "RealPower", "WindSpeed")

csv.data <- setnames(csv.data, c(names(csv.data)[1],
                                 names(csv.data)[2],
                                 names(csv.data)[3],
                                 names(csv.data)[4]),
                     c("TimeStamp10Min", "WTG", "RealPower", "WindSpeed")
)

write.csv(csv.data, "C:\\Users\\102957\\Documents\\R-Scripts\\Cedar Springs Scada.csv")
