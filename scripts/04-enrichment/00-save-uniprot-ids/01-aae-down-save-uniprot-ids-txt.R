# ~~~~~ EXTRACT UNIPROT IDS ~~~~~
# This basically does the same as 00-aae-save-uniprot-ids-txt.R, but for
# miRNAs that downregulated during DENV-2 infection in Aedes aegypti
# that are also present in the set with miRNAs up-regulated in Aedes albopictus during DENV-2 infection
# This script extracts uniprot IDs from each miRNA and saves them to .txt files
#
library(dplyr)
library(readr)

# ==== IMPORT DATA ====
# Load the miRNA dataframes inside of a list to iterate over them
# miRanda
source("scripts/03-mirna-target-pred/01-aae-add-target-names/03-aae-down-add-target-names.R")

# Load all targets
# miRanda
miranda_aae_uniprot_filtered <- read_csv("results/01-target-prediction/00-miRNAconsTarget/aae_down/miranda-aae-uniprot-filtered.csv")

# ==== EXTRACT UNIPROT IDS ====
# miRanda per miRNA
# Extract Uniprot IDs from each miRNA and save them to txt files
lapply(names(candidates_miranda), function(miRNA_name) {
  # Extract Uniprot IDs from uniprot_id column
  uniprot_ids <- candidates_miranda[[miRNA_name]]$uniprot_id
  # Save to txt file
  writeLines(uniprot_ids, con = paste0("results/02-enrichment/01-raw-input-output/input/aae-common-per-mirna/", miRNA_name, "-uniprot-aae-miranda.txt"))
})

# miRanda all
writeLines(miranda_aae_uniprot_filtered$uniprot_id, con = "results/02-enrichment/01-raw-input-output/input/aae-common-all/uniprot-aae-miranda-all.txt")
