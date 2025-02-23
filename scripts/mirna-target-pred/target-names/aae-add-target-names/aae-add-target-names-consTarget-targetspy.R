# ~~~~~ ADD TARGET NAMES ~~~~~ #
# ===== Load libraries & files =====
library("dplyr")
source("scripts/functions.R")

# ===== Importing data ===== #
# Add NA to all empty spaces
# ts
aae_ts <- read.delim("results/miRNAconsTarget/miRNAconsTarget_aae_all/targetspy-aae/targetspy-aae.csv")
