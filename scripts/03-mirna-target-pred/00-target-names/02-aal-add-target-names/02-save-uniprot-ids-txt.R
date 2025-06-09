# ~~~~~ EXTRACT UNIPROT IDS FROM EACH MIRNA AND SAVE THEM TO TXT FILES ~~~~~
library(dplyr)
# ==== IMPORT DF ====
# Load the miRNA dataframes inside of a list to iterate over them
# miRanda
source("scripts/03-mirna-target-pred/00-target-names/02-aal-add-target-names/00-aal-add-target-names-consTarget-miranda.R")

# TargetSpy
source("scripts/03-mirna-target-pred/00-target-names/02-aal-add-target-names/01-aal-add-target-names-consTarget-targetspy.R")

# Load all targets 
# miRanda
miranda_aal_uniprot_filtered <- read_csv("results/00-target-prediction/00-miRNAconsTarget/aal_up/miranda-aal/miranda-aal-uniprot-filtered.csv")

# TargetSpy
targetspy_aal_uniprot_filtered <- read_csv("results/00-target-prediction/00-miRNAconsTarget/aal_up/targetspy-aal/targetspy-aal-uniprot-filtered.csv")
 
# Extract Uniprot IDs from each miRNA and save them to txt files
lapply(names(candidates_miranda), function(miRNA_name) {
  # Extract Uniprot IDs from uniprot_id column
  uniprot_ids <- candidates_miranda[[miRNA_name]]$uniprot_id
  # Save to txt file
  writeLines(uniprot_ids, con = paste0("results/01-enrichment/shinygo/input/aal-miranda-per-mirna-shinygo/", miRNA_name, "-uniprot-aal-miranda.txt"))
})

# TargetSpy
writeLines(uniprot_ids_all_miranda, con = "results/01-enrichment/shinygo/input/uniprot-aal-miranda-all.txt")
# Extract Uniprot IDs from each miRNA and save them to txt files
lapply(names(candidates_targetspy), function(miRNA_name) {
  # Extract Uniprot IDs from uniprot_id column
  uniprot_ids <- candidates_targetspy[[miRNA_name]]$uniprot_id
  # Save to txt file
  writeLines(uniprot_ids, con = paste0("results/01-enrichment/shinygo/input/aal-ts-per-mirna-shinygo/", miRNA_name, "-uniprot-aal-ts.txt"))
})
writeLines(uniprot_ids_all_ts, con = "results/01-enrichment/shinygo/input/uniprot-aal-ts-all.txt")
