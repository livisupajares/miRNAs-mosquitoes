# ~~~~~ EXTRACT UNIPROT IDS FROM EACH MIRNA AND SAVE THEM TO TXT FILES ~~~~~
library(dplyr)

# ==== IMPORT DATA ====
# Load the miRNA dataframes inside of a list to iterate over them
# miRanda
source("scripts/03-mirna-target-pred/00-target-names/01-aae-add-target-names/02-aae-add-target-names-consTarget-miranda.R")

# TargetSpy
source("scripts/03-mirna-target-pred/00-target-names/01-aae-add-target-names/03-aae-add-target-names-consTarget-targetspy.R")

# ==== EXTRACT UNIPROT IDS ====
# miRanda per miRNA
# Extract Uniprot IDs from each miRNA and save them to txt files
lapply(names(candidates_miranda), function(miRNA_name) {
  # Extract Uniprot IDs from uniprot_id column
  uniprot_ids <- candidates_miranda[[miRNA_name]]$uniprot_id
  # Save to txt file
  write.table(uniprot_ids, file = paste0("results/shinygo/aae-miranda-shinygo/", miRNA_name, "-uniprot-aae-miranda", ".txt"), row.names = FALSE, col.names = FALSE)
})

# TargetSpy per miRNA
# Extract Uniprot IDs from each miRNA and save them to txt files
lapply(names(candidates_ts), function(miRNA_name) {
  # Extract Uniprot IDs from uniprot_id column
  uniprot_ids <- candidates_ts[[miRNA_name]]$uniprot_id
  # Save to txt file
  write.table(uniprot_ids, file = paste0("results/panther/aae-targetspy-pantherdb/uniprots-aae-targetspy/", miRNA_name, "-upid-aae-targetspy", ".txt"), row.names = FALSE, col.names = FALSE)
})
