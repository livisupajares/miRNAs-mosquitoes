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
# Can't use getSequence which is an easier way to fetch sequences, because it
# doesn't support metazoa ensembl datasets. It works with the main one only.
# Fetch 3'UTR sequences
utr3_sequences <- getSequence(
  mart = aedes_dataset,
  type = "3utr",
  seqType = "cdna"
)

# Error in getBM(attributes = c("ensembl_gene_id", "ensembl_transcript_id",  :
# Invalid filters(s): with_3_utr
# Please use the function 'listFilters' to get valid filter names
# listFilters(aedes_dataset) doesn't have anything that resembles 3' UTRs
utr3_annotations <- getBM(
  attributes = c("ensembl_gene_id", "ensembl_transcript_id", "3_utr_start", "3_utr_end", "chromosome_name", "strand"),
  filters = "with_3_utr",
  values = TRUE,
  mart = aedes_dataset
)

# View the first few rows of the result
head(utr3_annotations)
