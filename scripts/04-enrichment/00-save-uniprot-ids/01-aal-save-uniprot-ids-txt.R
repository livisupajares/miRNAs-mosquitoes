# ~~~~~ EXTRACT UNIPROT IDS FROM EACH MIRNA AND SAVE THEM TO TXT FILES ~~~~~
library(dplyr)
library(readr)
library(gtools)

# ==== IMPORT DATA ====
# Load the miRNA dataframes inside of a list to iterate over them
# miRanda
source("scripts/03-mirna-target-pred/00-target-names/02-aal-add-target-names/00-aal-add-target-names-consTarget-miranda.R")

# Load all targets
# miRanda
miranda_aal_uniprot_filtered <- read_csv("results/01-target-prediction/00-miRNAconsTarget/aal_up/miranda-aal/miranda-aal-uniprot-filtered.csv")

# ==== EXTRACT UNIPROT IDS ====
# miRanda per miRNA
# Extract Uniprot IDs from each miRNA and save them to txt files
lapply(names(candidates_miranda), function(miRNA_name) {
  # Extract Uniprot IDs and split by comma if needed
  uniprot_ids <- unlist(strsplit(as.character(candidates_miranda[[miRNA_name]]$uniprot_id), ","))

  # Remove empty strings if any
  uniprot_ids <- Filter(nzchar, uniprot_ids)

  # Save to txt file
  writeLines(uniprot_ids, con = paste0("results/02-enrichment/01-raw-input-output/shinygo/input/per-mirna/aal-miranda-per-mirna-shinygo/", miRNA_name, "-uniprot-aal-miranda.txt"))
})

# miRanda all
uniprot_ids_all_miranda <- unlist(strsplit(as.character(miranda_aal_uniprot_filtered$uniprot_id), ","))
uniprot_ids_all_miranda <- Filter(nzchar, uniprot_ids_all_miranda)
writeLines(uniprot_ids_all_miranda, con = "results/02-enrichment/01-raw-input-output/shinygo/input/all/uniprot-aal-miranda-all.txt")

# ===== DIVIDE ALL MIRNAS INTO 4 GROUPS ====
# At this point we haven't done the Venny processing, therefore we should save
# the list of aal miRNAs in a list, order them in ascending order and
# divide them into 4 groups of 6 miRNAs each. Then print the result.
# This will serve to copy and paste the uniprot IDs into venny's web server
# input boxes (which are a maximun of 4) manually from the per-mirnas txt files

# Extract the names of the miRNAs from the candidates_miranda list
mirna_names <- names(candidates_miranda)
print(mirna_names)

# Sort the miRNA names in ascending order where aal-miR-2a-3p is first and
# aal-miR-5706 is last
mirna_names_sorted <- rev(mixedsort(mirna_names))
print(mirna_names_sorted)

# Divide the sorted miRNA names into 4 groups of 6 miRNAs each
mirna_groups <- split(mirna_names_sorted, ceiling(seq_along(mirna_names_sorted) / 6))
print(mirna_groups)
