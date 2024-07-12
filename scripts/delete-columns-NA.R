# ~~~~~ DELETE NA COLUMNS ~~~~~~
# ===== Load libraries =====
library("tidyverse")
# ===== Importing diptera.csv =====
diptera <- read.table("databases/diptera.csv",
                      header = TRUE,
                      sep = ",")
