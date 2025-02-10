# ~~~~~ ADD TARGET NAMES ~~~~~ #
# if (!require("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
# 
# BiocManager::install("ensembldb")

# TODO : For the full database
# https://www.bioconductor.org/packages/devel/bioc/manuals/ensembldb/man/ensembldb.pdf

# ===== Load libraries & files ===== 
library("tidyverse")
library("ensembldb")
library("EnsDb.Hsapiens.v86") # Homo sapiens database

# ===== Importing data ===== #
# Add NA to all empty spaces
control <- read.delim("~/livisu/git/miRNAs-mosquitoes/results/filtar-results/control/control_miranda_target_predictions.txt")

# Eliminate all decimal parts without rounding
control$transcript_ID <- sub("\\..*", "", control$transcript_ID)

# ===== Subset df for testing ===== #
test_control <- head(control, 50)

# ===== CHECK PROT DATA ==== #
hsa <- EnsDb.Hsapiens.v86
hasProteinData(hsa)

