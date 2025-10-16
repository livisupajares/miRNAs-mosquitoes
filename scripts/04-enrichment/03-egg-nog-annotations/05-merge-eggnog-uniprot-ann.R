# ~~~~~ MERGE EGGNOG AND UNIPROT ANNOTATIONS ~~~~~
# This script will merge uniprot annotation table with eggnog annotation table by `uniprot_id`.
# Only selected rows will be picked for the merge.
# ===== LIBRARIES =====
library(dplyr)
library(tidylog, warn.conflicts = FALSE)

# ===== LOAD FILES =====
# Load eggnog annotation files
source("scripts/04-enrichment/03-egg-nog-annotations/04-eggnog-statistics.R")

# Remove unused data
rm(aae_all_down_eggnog)
rm(aae_all_eggnog)
rm(aae_per_mirna_down_eggnog)
rm(aae_per_mirna_eggnog)
rm(aal_all_eggnog)
rm(aal_per_mirna_eggnog)

# Load uniprot annotation files
aae_all_uniprot <- read.csv("results/02-enrichment/05-eggnog-annotation/aae_all_annotated.csv")
aae_all_down_uniprot <- read.csv("results/02-enrichment/05-eggnog-annotation/aae_all_down_annotated.csv")
aae_per_mirna_uniprot <- read.csv("results/02-enrichment/05-eggnog-annotation/aae_per_mirna_annotated.csv")
aae_per_mirna_down_uniprot <- read.csv("results/02-enrichment/05-eggnog-annotation/aae_per_mirna_down_annotated.csv")
aal_all_uniprot <- read.csv("results/02-enrichment/05-eggnog-annotation/aal_all_annotated.csv")
aal_per_mirna_uniprot <- read.csv("results/02-enrichment/05-eggnog-annotation/aal_per_mirna_annotated.csv")

# ===== TIDY DATA =====
# Filter eggnog dfs to keep only relevant columns for merging
eggnog_clean <- lapply(eggnog, function(df) {
  eggnog_clean <- df %>%
    select(uniprot_id, Description, Preferred_name, PFAMs) %>%
    return(df)
})

# Save cleaned eggnog dfs to variables
eggnog_aae_all_down <- eggnog_clean$aae_all_down
eggnog_aae_all <- eggnog_clean$aae_all
eggnog_aae_per_mirna <- eggnog_clean$aae_per_mirna
eggnog_aae_per_mirna_down <- eggnog_clean$aae_per_mirna_down
eggnog_aal_all <- eggnog_clean$aal_all
eggnog_aal_per_mirna <- eggnog_clean$aal_per_mirna

# Merge databases
aae_all_merged <- merge(aae_all_uniprot, eggnog_aae_all, by.x = "matching_proteins_id_network", by.y = "uniprot_id", all.x = TRUE)
aae_all_down_merged <- merge(aae_all_down_uniprot, eggnog_aae_all_down, by.x = "matching_proteins_id_network", by.y = "uniprot_id", all.x = TRUE)
aae_per_mirna_merged <- merge(aae_per_mirna_uniprot, eggnog_aae_per_mirna, by.x = "matching_proteins_id_network", by.y = "uniprot_id", all.x = TRUE)
aae_per_mirna_down_merged <- merge(aae_per_mirna_down_uniprot, eggnog_aae_per_mirna_down, by.x = "matching_proteins_id_network", by.y = "uniprot_id", all.x = TRUE)
aal_all_merged <- merge(aal_all_uniprot, eggnog_aal_all, by.x = "matching_proteins_id_network", by.y = "uniprot_id", all.x = TRUE)
aal_per_mirna_merged <- merge(aal_per_mirna_uniprot, eggnog_aal_per_mirna, by.x = "matching_proteins_id_network", by.y = "uniprot_id", all.x = TRUE)

# TODO: Save merged databases into a list
# TODO: Sort by term_description
# TODO: Rename uniprot and eggnog annotation columns
