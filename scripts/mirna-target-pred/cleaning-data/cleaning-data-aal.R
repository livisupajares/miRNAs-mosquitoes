# ~~~~~ TEST = ISOLATE AEDES ALBOPICTUS MIRNA SEQUENCES ~~~~~~
#
# ===== Load libraries & files ===== 
# library("tidyverse")
source("scripts/functions.R")

# ===== Importing data ===== 
# Add NA to all empty spaces
aal_mirna <- read.csv("sequences/aal-complete/aal-mirna-seq-U.csv",
                      na.strings = c("","NA"))
