# ~~~~~ ADD TARGET NAMES ~~~~~ #
# if (!require("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
# 
# BiocManager::install("ensembldb")
# BiocManager::install("EnsDb.Hsapiens.v86")

# https://www.bioconductor.org/packages/devel/bioc/manuals/ensembldb/man/ensembldb.pdf

# ===== Load libraries & files ===== 
library("dplyr")
library("ensembldb")
library("EnsDb.Hsapiens.v86") # Homo sapiens database
source("scripts/functions.R")

