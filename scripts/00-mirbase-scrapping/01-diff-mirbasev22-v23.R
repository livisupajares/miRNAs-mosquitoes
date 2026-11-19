# ~~~~~ DIFF CHECKER MIRBASE VERSIONS ~~~~~~ 
# This script checks which miRNAs and sequences
# are different between the previous miRBase version (22)
# and the current one (23.1)

# ==== IMPORT LIBRARIES =====
library(dplyr)
library(tidyr)
library(readxl)

# ==== IMPORT DATA ====
aae_mirbase23 <- read.csv("databases/00-mirbase-scrapping/aae-v23.csv")
table_s1 <- read_excel("databases/00-mirbase-scrapping/table-s1.xlsx",
  sheet = "Aedes aegypti", range = "A1:D263"
)
