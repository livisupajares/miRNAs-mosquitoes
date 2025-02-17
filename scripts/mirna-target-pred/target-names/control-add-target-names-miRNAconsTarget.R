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

# ===== Importing data ===== #
# Add NA to all empty spaces
# Miranda
control_miranda <- read.delim("results/miRNAconsTarget/miRNAconsTarget_hsa_controles_all/miranda/miranda.csv")
# ts
control_ts <- read.delim("results/miRNAconsTarget/miRNAconsTarget_hsa_controles_all/targetspy/ts.csv")
# PITA
control_pita <- read.delim("results/miRNAconsTarget/miRNAconsTarget_hsa_controles_all/pita/pita.csv")

# ==== FIX DATA ==== #
# Eliminate all decimal parts without rounding
control_miranda$mRNA <- sub("\\..*", "", control_miranda$mRNA)
control_ts$mRNA <- sub("\\..*", "", control_ts$mRNA)
control_pita$mRNA <- sub("\\..*", "", control_pita$mRNA)

# ===== CHECK PROT DATA ==== #
hsa <- EnsDb.Hsapiens.v86
hasProteinData(hsa)

# ===== API ENSEMBL ===== #
# test only for one transcript ID
tx_miranda <- transcripts(hsa, filter = TxIdFilter(control_miranda$mRNA), columns = c("tx_id", "uniprot_id", "gene_name"))
tx_ts <- transcripts(hsa, filter = TxIdFilter(control_ts$mRNA), columns = c("tx_id", "uniprot_id", "gene_name"))
tx_pita <- transcripts(hsa, filter = TxIdFilter(control_pita$mRNA), columns = c("tx_id", "uniprot_id", "gene_name"))

