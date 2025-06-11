# ~~~~~ EXTRACT UNIPROT IDS FROM EACH MIRNA AND SAVE THEM TO TXT FILES ~~~~~
library(dplyr)
library(readr)

# ==== IMPORT DATA ====
# Load the miRNA dataframes inside of a list to iterate over them
# miRanda
source("scripts/03-mirna-target-pred/00-target-names/01-aae-add-target-names/02-aae-add-target-names-consTarget-miranda.R")

# TargetSpy
source("scripts/03-mirna-target-pred/00-target-names/01-aae-add-target-names/03-aae-add-target-names-consTarget-targetspy.R")

# Load all targets
# miRanda
miranda_aae_uniprot_filtered <- read_csv("results/00-target-prediction/00-miRNAconsTarget/aae_up/miranda-aae/miranda-aae-uniprot-filtered.csv")

# TargetSpy
targetspy_aae_uniprot_filtered <- read_csv("results/00-target-prediction/00-miRNAconsTarget/aae_up/targetspy-aae/targetspy-aae-uniprot-filtered.csv")

# ==== EXTRACT UNIPROT IDS ====
# miRanda per miRNA
# Extract Uniprot IDs from each miRNA and save them to txt files
lapply(names(candidates_miranda), function(miRNA_name) {
  # Extract Uniprot IDs from uniprot_id column
  uniprot_ids <- candidates_miranda[[miRNA_name]]$uniprot_id
  # Save to txt file
  writeLines(uniprot_ids, con = paste0("results/01-enrichment/shinygo/input/aae-miranda-per-mirna-shinygo/", miRNA_name, "-uniprot-aae-miranda.txt"))
})

# miRanda all
writeLines(miranda_aae_uniprot_filtered$uniprot_id, con = "results/01-enrichment/shinygo/input/uniprot-aae-miranda-all.txt")

# TargetSpy per miRNA
# Extract Uniprot IDs from each miRNA and save them to txt files
lapply(names(candidates_ts), function(miRNA_name) {
  # Extract Uniprot IDs from uniprot_id column
  uniprot_ids <- candidates_ts[[miRNA_name]]$uniprot_id
  # Save to txt file
  writeLines(uniprot_ids, con = paste0("results/01-enrichment/shinygo/input/aae-ts-per-mirna-shinygo/", miRNA_name, "-uniprot-aae-targetspy.txt"))
})

# TargetSpy all
writeLines(targetspy_aae_uniprot_filtered$uniprot_id, con = "results/01-enrichment/shinygo/input/uniprot-aae-ts-all.txt")
