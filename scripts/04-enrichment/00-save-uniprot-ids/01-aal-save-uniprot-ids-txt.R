# ~~~~~ EXTRACT UNIPROT IDS FROM EACH MIRNA AND SAVE THEM TO TXT FILES ~~~~~
library(dplyr)
library(readr)

# ==== IMPORT DATA ====
# Load the miRNA dataframes inside of a list to iterate over them
# miRanda
source("scripts/03-mirna-target-pred/00-target-names/02-aal-add-target-names/00-aal-add-target-names-consTarget-miranda.R")

# Load all targets
# miRanda
miranda_aal_uniprot_filtered <- read_csv("results/00-target-prediction/00-miRNAconsTarget/aal_up/miranda-aal/miranda-aal-uniprot-filtered.csv")

# ==== EXTRACT UNIPROT IDS ====
# miRanda per miRNA
# Extract Uniprot IDs from each miRNA and save them to txt files
lapply(names(candidates_miranda), function(miRNA_name) {
  # Extract Uniprot IDs and split by comma if needed
  uniprot_ids <- unlist(strsplit(as.character(candidates_miranda[[miRNA_name]]$uniprot_id), ","))

  # Remove empty strings if any
  uniprot_ids <- Filter(nzchar, uniprot_ids)

  # Save to txt file
  writeLines(uniprot_ids, con = paste0("results/01-enrichment/shinygo/input/aal-miranda-per-mirna-shinygo/", miRNA_name, "-uniprot-aal-miranda.txt"))
})

# miRanda all
uniprot_ids_all_miranda <- unlist(strsplit(as.character(miranda_aal_uniprot_filtered$uniprot_id), ","))
uniprot_ids_all_miranda <- Filter(nzchar, uniprot_ids_all_miranda)
writeLines(uniprot_ids_all_miranda, con = "results/01-enrichment/shinygo/input/uniprot-aal-miranda-all.txt")
