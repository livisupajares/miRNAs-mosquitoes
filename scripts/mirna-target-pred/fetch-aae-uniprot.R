# ~~~~~~~FETCH UNIPROT CODES FROM AAE TRANSCRIPTOME (ENSEMBLR) ~~~~~~~
# ==== Load required libraries ====
# Instructions to install bioconductor packages
# if (!requireNamespace("BiocManager", quietly = TRUE)) {
#   install.packages("BiocManager")
# }
# BiocManager::install("biomaRt")
# BiocManager::install("Biostrings")

library(biomaRt)
source("scripts/functions.R")

# ==== Connect to Ensembl ====
# List available Ensembl Metazoa databases
listMarts(host = "https://metazoa.ensembl.org")
