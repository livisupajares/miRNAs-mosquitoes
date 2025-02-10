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

