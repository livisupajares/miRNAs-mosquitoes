# ~~~~~~~FETCH UNIPROT CODES FROM AAE TRANSCRIPTOME (ENSEMBLR) ~~~~~~~
# ==== Load required libraries ====
# Instructions to install bioconductor packages
# if (!requireNamespace("BiocManager", quietly = TRUE)) {
#   install.packages("BiocManager")
# }
# BiocManager::install("biomaRt")
# BiocManager::install("Biostrings")

library(biomaRt)
library(dplyr)

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

# ==== Inspect data ====
# View the first few rows of the result
head(uniprots_aae)

# ==== Clean data ====
# Remove 3rd column
uniprots_aae$external_gene_name <- NULL

# Replace all empty values with NA using dplyr
uniprots_aae <- uniprots_aae %>%
  mutate_all(~ na_if(., ""))

# Merge NA uniprotsptrembl values with uniparc values using dplyr
uniprots_aae <- uniprots_aae %>%
  mutate(uniprotsptrembl = coalesce(uniprotsptrembl, uniparc)) %>%
  select(-uniparc)

# ==== Save data ====
# Save the cleaned data to a CSV file
write.csv(uniprots_aae, "results/00-target-prediction/01-ensembl-metazoa-biomart/uniprots_aae_biomart.csv", row.names = FALSE)
