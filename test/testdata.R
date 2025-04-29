

csv.data <- read.csv("C:\\Users\\102957\\OneDrive - Underwriters Laboratories\\Desktop\\GitHub\\Wind_Turbine_SCADA_Review\\Test_Site_data.csv")
csv.data$Rating <- 2820

AddDF <- data.frame(
  WTG = c("WTG-0001",
          "WTG-0014",
          "WTG-0019",
          "WTG-0060",
          "WTG-0071"
          ),
  Rating2 = c(2520)
)

for (i in 1:NROW(AddDF)){
       turbine <- AddDF$WTG[i]
       rate <- AddDF$Rating2[i]
       csv.data$Rating[csv.data$WTG == turbine] <- rate
}

# List the name of the wind farm 
SiteName <- "Test"

WTG.Models <- data.frame(
  `Site Name` = "Test",
  `WTG Count` = c(68, 5),
  Manufacturer = c("GE 2.82-127", "GE 2.52-116"),
  `WTG Rating` = c("2820", "2520")
)




names(WTG.Models)[4] <- "Rating (kW)"

# Enter the total number of WTGs listed from Site. This will be used to verify the Total WTGs vs the 
# data set that was giving. This way we can see if the data is missing any WTGs.
Total.Num.WTgs <- as.numeric(length(unique(csv.data$WTG)))
wtgs <- unique(csv.data$WTG)
