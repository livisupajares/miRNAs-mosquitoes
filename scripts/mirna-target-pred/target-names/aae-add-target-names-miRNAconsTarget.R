# ~~~~~ ADD TARGET NAMES ~~~~~ #
# if (!require("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
#
# BiocManager::install("biomaRt")

# ===== Load libraries & files =====
library("dplyr")
library("biomaRt")
source("scripts/functions.R")

# ===== Importing data ===== #
# Add NA to all empty spaces
# Miranda
aae_miranda <- read.delim("results/miRNAconsTarget/miRNAconsTarget_aae_all/miranda-aae/miranda-aae.csv")
# ts
aae_ts <- read.delim("results/miRNAconsTarget/miRNAconsTarget_aae_all/targetspy-aae/targetspy-aae.csv")

# ==== FIX DATA ==== #
# Eliminate all decimal parts without rounding
aae_miranda$mRNA <- sub("\\..*", "", aae_miranda$mRNA)
aae_ts$mRNA <- sub("\\..*", "", aae_ts$mRNA)
aae_pita$mRNA <- sub("\\..*", "", aae_pita$mRNA)
