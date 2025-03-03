# ~~~~~ EXTRACT UNIPROT IDS FROM EACH MIRNA AND SAVE THEM TO TXT FILES ~~~~~
library(dplyr)
# ==== IMPORT DF ====
# Load the miRNA dataframes inside of a list to iterate over them
source("scripts/mirna-target-pred/target-names/aae-add-target-names/aae-add-target-names-consTarget-miranda.R")
source("scripts/mirna-target-pred/target-names/aae-add-target-names/aae-add-target-names-consTarget-targetspy.R")

# ==== EXTRACT UNIPROT IDS ====
# miRanda
# Extract Uniprot IDs from each miRNA and save them to txt files
lapply(names(candidates_miranda), function(miRNA_name) {
  # Extract Uniprot IDs from uniprot_id column
  uniprot_ids <- candidates_miranda[[miRNA_name]]$uniprot_id
  # Save to txt file
  write.table(uniprot_ids, file = paste0("results/panther/aae-miranda-pantherdb/uniprots-aae-miranda/", miRNA_name, "-upid-aae-miranda", ".txt"), row.names = FALSE, col.names = FALSE)
})

# TargetSpy
# Extract Uniprot IDs from each miRNA and save them to txt files
lapply(names(candidates_ts), function(miRNA_name) {
  # Extract Uniprot IDs from uniprot_id column
  uniprot_ids <- candidates_ts[[miRNA_name]]$uniprot_id
  # Save to txt file
  write.table(uniprot_ids, file = paste0("results/panther/aae-targetspy-pantherdb/uniprots-aae-targetspy/", miRNA_name, "-upid-aae-targetspy", ".txt"), row.names = FALSE, col.names = FALSE)
})
