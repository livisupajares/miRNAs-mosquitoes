# ~~~~~ SEPARATE DF BY SPECIES ~~~~~
# This script prepares the data to be used in BLAST analysis for further annotation by separating these dataframes by species.
#
# ===== Add libraries =====
library(dplyr)
library(tidylog, warn.conflicts = FALSE)

# ===== Import data =====
full_expanded_all_down_stringdb_annotated <- read_csv("results/02-enrichment/04-enrich-full-anotation/output_annotation/full-expanded-all-down-stringdb_annotated.csv")
full_expanded_all_stringdb_annotated <- read_csv("results/02-enrichment/04-enrich-full-anotation/output_annotation/full-expanded-all-stringdb_annotated.csv")
full_expanded_per_mirna_down_stringdb_annotated <- read_csv("results/02-enrichment/04-enrich-full-anotation/output_annotation/full-expanded-per-mirna-down-stringdb_annotated.csv")
full_expanded_per_mirna_stringdb_annotated <- read_csv("results/02-enrichment/04-enrich-full-anotation/output_annotation/full-expanded-per-mirna-stringdb_annotated.csv")

# ==== Inspect species variables =====
# See the unique values of species column to see which dfs we need to separate
full_expanded_all_down_stringdb_annotated %>%
  distinct(species) # Aedes aegypti only
full_expanded_all_stringdb_annotated %>%
  distinct(species) # Aedes aegypti and Aedes albopictus
full_expanded_per_mirna_down_stringdb_annotated %>%
  distinct(species) # Aedes aegypti only
full_expanded_per_mirna_stringdb_annotated %>%
  distinct(species) # Aedes aegypti and Aedes albopictus

# ==== Separate dfs by species =====
# For full_expanded_all_stringdb_annotated
aae_all_annotated <- full_expanded_all_stringdb_annotated %>%
  filter(species == "Aedes aegypti")

aal_all_annotated <- full_expanded_all_stringdb_annotated %>%
  filter(species == "Aedes albopictus")

# For full_expanded_per_mirna_stringdb_annotated
aae_per_mirna_annotated <- full_expanded_per_mirna_stringdb_annotated %>%
  filter(species == "Aedes aegypti")
aal_per_mirna_annotated <- full_expanded_per_mirna_stringdb_annotated %>%
  filter(species == "Aedes albopictus")

# ==== Remove unused dfs ====
rm(full_expanded_all_stringdb_annotated)
rm(full_expanded_per_mirna_stringdb_annotated)

# ==== Statistics =====
# Store dataframes in a list for easier processing
df_list <- list(
  "aae_all_down" = full_expanded_all_down_stringdb_annotated,
  "aae_all" = aae_all_annotated,
  "aae_per_mirna" = aae_per_mirna_annotated,
  "aae_per_mirna_down" = full_expanded_per_mirna_down_stringdb_annotated,
  "aal_all" = aal_all_annotated,
  "aal_per_mirna" = aal_per_mirna_annotated
)

# Count how many unique uniprot ids (matching proteins_id_ network) have protein_name, cc_function, go_p and go_f as NAs

cat("=== UniProt IDs with ALL 4 columns as NA ===\n")

for (name in names(df_list)){
  df <- df_list[[name]]
  # Filter rows where all 4 columns are NA, then get unique proteins_id_network
  uniprot_all_na <- df %>%
    filter(is.na(protein_name) & is.na(cc_function) & is.na(go_p) & is.na(go_f)) %>%
    pull(matching_proteins_id_network) %>%
    unique()
  cat(name,"\n")
  cat(sprintf("Count: %d\n", length(uniprot_all_na)))
  if (length(uniprot_all_na) > 0) {
    cat("UniProt IDs:\n")
    print(uniprot_all_na)
  } else {
    cat("No UniProt IDs found with all 4 columns as NA.\n")
  }
  cat("\n")
}

# Count how many unique uniprot ids (matching proteins_id_ network) have only protein_name as NA
cat("=== UniProt IDs with ONLY protein_name as NA ===\n")

for (name in names(df_list)){
  df <- df_list[[name]]
  uniprot_only_protein_name_na <- df %>%
    filter(is.na(protein_name)) %>%
    pull(matching_proteins_id_network) %>%
    unique()
  cat(name,"\n")
  cat(sprintf("Count: %d\n", length(uniprot_only_protein_name_na)))
  if (length(uniprot_only_protein_name_na) > 0) {
    cat("UniProt IDs:\n")
    print(uniprot_only_protein_name_na)
  } else {
    cat("No UniProt IDs found with only protein_name as NA.\n")
  }
  cat("\n")
}


# ==== Save final df =====
write.csv(full_expanded_all_down_stringdb_annotated, file = "results/02-enrichment/05-blast-annotation/aae_all_down_annotated.csv", row.names = FALSE)
write.csv(aae_all_annotated, file = "results/02-enrichment/05-blast-annotation/aae_all_annotated.csv", row.names = FALSE)
write.csv(aal_all_annotated, file = "results/02-enrichment/05-blast-annotation/aal_all_annotated.csv", row.names = FALSE)
write.csv(full_expanded_per_mirna_down_stringdb_annotated, file = "results/02-enrichment/05-blast-annotation/aae_per_mirna_down_annotated.csv", row.names = FALSE)
write.csv(aae_per_mirna_annotated, file = "results/02-enrichment/05-blast-annotation/aae_per_mirna_annotated.csv", row.names = FALSE)
write.csv(aal_per_mirna_annotated, file = "results/02-enrichment/05-blast-annotation/aal_per_mirna_annotated.csv", row.names = FALSE)
