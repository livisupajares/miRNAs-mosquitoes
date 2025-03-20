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

# Connect to Ensembl Metazoa database
ensembl_metazoa <- useMart(
  biomart = "metazoa_mart",
  host = "https://metazoa.ensembl.org"
)

# List available datasets
datasets <- listDatasets(ensembl_metazoa)

# Specify the dataset for Aedes aegypti
aedes_dataset <- useDataset(
  "aalvpagwg_eg_gene",
  mart = ensembl_metazoa
)

# ==== Fetch uniprot metadata ====
# Fetch attributes for metadata aae
uniprots_aae <- getBM(
  attributes = c("ensembl_gene_id", "ensembl_transcript_id", "external_gene_name", "uniprotsptrembl", "uniparc"),
  values = TRUE,
  mart = aedes_dataset
)
