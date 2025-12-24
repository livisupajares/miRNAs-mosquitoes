# ~~~~~ EXTRACT UNIPROT IDS FROM EACH MIRNA AND SAVE THEM TO TXT FILES ~~~~~
library(dplyr)
library(readr)

# ==== IMPORT DATA ====
# Load the miRNA dataframes inside of a list to iterate over them
# miRanda
source("scripts/03-mirna-target-pred/02-aal-add-target-names/00-aal-add-target-names.R")

# Load all targets
# miRanda
miranda_aal_uniprot_filtered <- read_csv("results/01-target-prediction/00-miRNAconsTarget/aal_up/miranda-aal-uniprot-filtered.csv") # 610

# ==== EXTRACT UNIPROT IDS ====
# miRanda per miRNA
# Extract Uniprot IDs from each miRNA and save them to txt files
lapply(names(candidates_miranda), function(miRNA_name) {
  # Extract Uniprot IDs and split by comma if needed
  uniprot_ids <- unlist(strsplit(as.character(candidates_miranda[[miRNA_name]]$uniprot_id), ","))

  # Remove empty strings if any
  uniprot_ids <- Filter(nzchar, uniprot_ids)

  # Save to txt file
  writeLines(uniprot_ids, con = paste0("results/02-enrichment/01-raw-input-output/input/per-mirna/aal-miranda-per-mirna/", miRNA_name, "-uniprot-aal-miranda.txt"))
})

# miRanda all
# This part of the script extracts all Uniprot IDs from miranda_aal_uniprot_filtered. In total there are 610 rows, so ideally we should have 610 uniprot ids. However, each row has multiple uniprot ids separated by commas. They map to the same VectoBase ID, therefore is the same protein. Therefore, we need to split them (unlist) and save them in a single txt file. After unlisting, we get 868 unique uniprot IDS mapping to the same protein (VectorBase ID)
uniprot_ids_all_miranda <- unlist(strsplit(as.character(miranda_aal_uniprot_filtered$uniprot_id), ",")) # 868
uniprot_ids_all_miranda <- Filter(nzchar, uniprot_ids_all_miranda)
writeLines(uniprot_ids_all_miranda, con = "results/02-enrichment/01-raw-input-output/input/all/uniprot-aal-miranda-all.txt")
