# ~~~~~~~FETCH 3'UTR SEQUENCES FROM AAE TRANSCRIPTOME (ENSEMBLR) ~~~~~~~
# ==== Load required libraries ====
# Instructions to install bioconductor packages
# if (!requireNamespace("BiocManager", quietly = TRUE)) {
#   install.packages("BiocManager")
# }
# BiocManager::install("biomaRt")
# BiocManager::install("Biostrings")

library(biomaRt)
library(Biostrings)

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

# ==== Fetch 3'UTR sequences ====
# Fetch attributes for 3'UTR sequences
utr3_annotations <- getBM(
  attributes = c("ensembl_transcript_id", "3utr"), # "3utr" is the sequence
  values = TRUE,
  mart = aedes_dataset
)

# ==== Inspect data ====
# View the first few rows of the result
head(utr3_annotations)
