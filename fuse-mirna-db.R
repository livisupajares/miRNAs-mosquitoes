# ~~~~~ FUSING DATA ~~~~~
# 
# ===== Load libraries =====
library("tidyverse")

# ===== Fixing data =====
# Aedes aegypti
aae <- read.table("mirbase-diptera-scrapped/aae.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))