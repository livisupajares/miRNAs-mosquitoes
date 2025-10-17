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

# Save merged databases into a list
annotation <- list(
  "aae_all_merged" = aae_all_merged,
  "aae_all_down_merged" = aae_all_down_merged,
  "aae_per_mirna_merged" = aae_per_mirna_merged,
  "aae_per_mirna_down_merged" = aae_per_mirna_down_merged,
  "aal_all_merged" = aal_all_merged,
  "aal_per_mirna_merged" = aal_per_mirna_merged
)
# Clean new df list
annotation_sorted <- lapply(annotation, function(df) {
  annotation_sorted <- df %>% 
    # Sort by term_description
    arrange(term_description) %>%
    # Rename column to uniprot_id
    rename(uniprot_id = matching_proteins_id_network) %>%
    # Rename uniprot and eggnog annotation columns
    rename(annotation_stringdb = annotation) %>%
    rename(protein_name_uniprot = protein_name) %>%
    rename(cc_function_uniprot = cc_function) %>%
    rename(go_p_uniprot = go_p) %>%
    rename(go_f_uniprot = go_f)%>%
    rename(description_eggnog = Description) %>%
    rename(preferred_name_eggnog = Preferred_name) %>%
    rename(pfams_eggnog = PFAMs) %>%
    # Relocate eggnog annotation columns after `go_f_uniprot`
    relocate(c(description_eggnog, preferred_name_eggnog, pfams_eggnog), .after = go_f_uniprot)
})

# ==== SAVE DFS ====
write.csv(annotation_sorted$aae_all_merged, "results/02-enrichment/07-tidying-results/01-uniprot-eggnog/aae-all-merged.csv", row.names = FALSE)
write.csv(annotation_sorted$aae_all_down_merged, "results/02-enrichment/07-tidying-results/01-uniprot-eggnog/aae-all-down-merged.csv", row.names = FALSE)
write.csv(annotation_sorted$aae_per_mirna_merged, "results/02-enrichment/07-tidying-results/01-uniprot-eggnog/aae-per-mirna-merged.csv", row.names = FALSE)
write.csv(annotation_sorted$aae_per_mirna_down_merged, "results/02-enrichment/07-tidying-results/01-uniprot-eggnog/aae-per-mirna-down-merged.csv", row.names = FALSE)
write.csv(annotation_sorted$aal_all_merged, "results/02-enrichment/07-tidying-results/01-uniprot-eggnog/aal-all-merged.csv", row.names = FALSE)
write.csv(annotation_sorted$aal_per_mirna_merged, "results/02-enrichment/07-tidying-results/01-uniprot-eggnog/aal-per-mirna-merged.csv", row.names = FALSE)
