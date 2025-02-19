# ~~~~~ ADD TARGET NAMES ~~~~~ #
# ===== Load libraries & files ===== 
library("dplyr")
source("scripts/functions.R")

# ===== Importing data ===== #
# Add NA to all empty spaces
# Miranda
aae_miranda <- read.delim("results/miRNAconsTarget/miRNAconsTarget_aae_all/miranda/miranda.csv")
# ts
aae_ts <- read.delim("results/miRNAconsTarget/miRNAconsTarget_aae_all/ts/ts.csv")
# PITA
aae_pita <- read.delim("results/miRNAconsTarget/miRNAconsTarget_aae_all/pita/pita.csv")
