# ~~~~~ FILTER DIPTERA.CSV ~~~~~~
# ===== Load libraries =====
library("tidyverse")
# ===== Importing diptera.csv =====
diptera <- read.table("databases/diptera.csv",
                      header = TRUE,
                      sep = ",")
# ===== FILTER DATA =====
# Filter diptera by conf high
conf_high <- filter(diptera,
                    conf == "High")
## Save conf_high to .csv
write.csv(conf_high,
          "databases/diptera-conf-high.csv",
          row.names = FALSE)

# Filter diptera by conf not enough data
conf_low <- filter(diptera,
                    conf == "Not enough data")
## Save conf_low to .csv
write.csv(conf_low,
          "databases/diptera-conf-low.csv",
          row.names = FALSE)