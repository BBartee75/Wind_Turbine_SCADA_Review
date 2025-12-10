library(data.table)
library(lubridate)
library(dplyr)
library(openxlsx)
library(tidyr)
source("C:\\Users\\102957\\Documents\\R-Scripts\\Bently Codes\\BBar_Wind Energy Functions.R")
source("C:\\Users\\102957\\Documents\\R-Scripts\\Bently Codes\\My Functions_BBartee.R")

#---------------------------------------------------------------------------------------------------
#colnames c("WTG", "TimeStamp10Min", "RealPower", "WindSpeed")


File.loc <- "./Downloaded_Data/"
File_xlsx <- "lane city ULS report.xlsx"

x1 <- readxl::read_xlsx(paste0(File.loc, File_xlsx), # if date issues use: readxl::read_xlsx , normal openxlsx::read.xlsx
                        sheet = "WindSpeed")


# x1 <- x1 %>%  mutate(across(starts_with("T"), ~ {
#   # Check if the value is a character string and contains the pattern
#   if (is.character(.)) {
#     gsub("^-?\\s*\\[-?\\d+\\]\\s*No\\s*Good\\s*Data\\s*For\\s*Calculation\\s*$", "0", ., perl = TRUE)
#   } else {
#     . # If not a character, return the value as is
#   }
# })) %>%
#   # Now convert all 'T' columns to numeric.
#   # Coercion will turn non-numeric values (which should now only be the actual numbers) into numeric.
#   mutate(across(starts_with("T"), as.numeric))


x1 <- x1 %>%
  tidyr::pivot_longer(cols = -PCTimeStamp,
                      names_to = "WTG",
                      values_to = "WindSpeed") #WindSpeed

x1 <- data.table::setnames(x1, "PCTimeStamp", "TimeStamp10Min")


#---------------------------------------------------------------------------------------------------

x2 <- readxl::read_xlsx(paste0(File.loc, File_xlsx), # if date issues use: readxl::read_xls, normal openxlsx::read.xlsx
                        sheet = "ActivePower")

# x2 <- x2 %>%
#   mutate(across(starts_with("T"), ~ {
#     # Check if the value is a character string and contains the pattern
#     if (is.character(.)) {
#       gsub("^-?\\s*\\[-?\\d+\\]\\s*No\\s*Good\\s*Data\\s*For\\s*Calculation\\s*$", "0", ., perl = TRUE)
#     } else {
#       . # If not a character, return the value as is
#     }
#   })) %>%
#   # Now convert all 'T' columns to numeric.
#   # Coercion will turn non-numeric values (which should now only be the actual numbers) into numeric.
#   mutate(across(starts_with("T"), as.numeric))


x2 <- x2 %>%
  tidyr::pivot_longer(cols = -PCTimeStamp,
                      names_to = "WTG",
                      values_to = "RealPower") #RealPower
x2 <- data.table::setnames(x2, "PCTimeStamp", "TimeStamp10Min")


csv.data <- merge(x1, x2, by = c("TimeStamp10Min", "WTG"))
csv.data[is.na(csv.data)] <- 0

csv.data <- csv.data %>%
  mutate(
    TimeStamp10Min = if_else(
      !grepl("^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}$", as.character(TimeStamp10Min)),
      lubridate::as_datetime(TimeStamp10Min),
      lubridate::as_datetime(TimeStamp10Min)  # Parse to ensure POSIXct class consistency
    )
  )

#write.csv(csv.data, paste0("./Downloaded_Data/","LaneCity.csv"))
fwrite(csv.data, paste0("./Downloaded_Data/","LaneCity.csv"))


