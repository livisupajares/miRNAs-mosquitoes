# ~~~~~ EXTRACT UNIPROT IDS FROM EACH MIRNA AND SAVE THEM TO TXT FILES ~~~~~
library(dplyr)
library(readr)

# ==== IMPORT DATA ====
# Load the miRNA dataframes inside of a list to iterate over them
# miRanda
source("scripts/03-mirna-target-pred/00-target-names/01-aae-add-target-names/02-aae-add-target-names-consTarget-miranda.R")

# Load all targets
# miRanda
miranda_aae_uniprot_filtered <- read_csv("results/01-target-prediction/00-miRNAconsTarget/aae_up/miranda-aae/miranda-aae-uniprot-filtered.csv")

# ==== EXTRACT UNIPROT IDS ====
# miRanda per miRNA
# Extract Uniprot IDs from each miRNA and save them to txt files
lapply(names(candidates_miranda), function(miRNA_name) {
  # Extract Uniprot IDs from uniprot_id column
  uniprot_ids <- candidates_miranda[[miRNA_name]]$uniprot_id
  # Save to txt file
  writeLines(uniprot_ids, con = paste0("results/02-enrichment/01-raw-input-output/stringdb/input/per-mirna/aae-miranda-per-mirna/", miRNA_name, "-uniprot-aae-miranda.txt"))
})

# miRanda all
writeLines(miranda_aae_uniprot_filtered$uniprot_id, con = "results/02-enrichment/01-raw-input-output/stringdb/input/all/uniprot-aae-miranda-all.txt")
