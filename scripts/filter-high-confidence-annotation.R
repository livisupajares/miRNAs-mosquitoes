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
# Filter diptera by conf not enough data
conf_low <- filter(diptera,
                    conf == "Not enough data")
