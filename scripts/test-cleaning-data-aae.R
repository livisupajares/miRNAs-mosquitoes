# ~~~~~ TEST = ISOLATING AEDES AEGYPTI MIRNA SEQUENCES ~~~~~~
#
# ===== Load libraries & files ===== 
library("tidyverse")

# ===== Importing data ===== 
# Add NA to all empty spaces
aae_mirna <- read.csv("databases/test/aae-mirna-seq.csv",
                      na.strings = c("","NA"))

