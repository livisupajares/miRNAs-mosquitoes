# ~~~~~ PROTEINS OF ENRICHED PROCESES ~~~~~~
# This script splits the genes and pathway_genes into a list of protein ids for each enriched process.
# Then each list is saved into a dataframe with the process name and the list of protein ids.
# Then, the list of protein ids is matched to their names and/or descriptions with imported dataframes of mapped protein ids from stringdb.

# ==== Load libraries ====
library(dplyr)
library(tidyr)
library("tidylog", warn.conflicts = FALSE)

# ==== IMPORT DATA ====
## Import enriched processes data
# Per miRNA
#important_per_mirna_stringdb <- read.csv("results/02-enrichment/03-enrichments-important-process/important-per-mirna-stringdb.csv")
# Import all enriched processes not only the ones who don't have category of interest as NA
important_per_mirna_stringdb <- read.csv("results/02-enrichment/03-enrichments-important-process/per-mirna-stringdb.csv")

# Venny
important_venny_stringdb <- read.csv("results/02-enrichment/03-enrichments-important-process/important-venny-stringdb.csv") # No enrichments

# All
# important_all_stringdb <- read.csv("results/02-enrichment/03-enrichments-important-process/important-all-stringdb.csv")
important_all_stringdb <- read.csv("results/02-enrichment/03-enrichments-important-process/all-stringdb.csv")

# Aae down-regulated
# Per miRNA
aae_per_mirna_down <- read.csv("results/02-enrichment/02-exports-google-sheets/aae-per-mirna-down-stringdb-export.csv")

# All
aae_all_down <- read.csv("results/02-enrichment/02-exports-google-sheets/aae-all-down-stringdb-export.csv")

## Import mapped protein ids from stringdb
aae_mapped_protein_ids_stringdb <- read.csv("databases/03-enrichment/aae-mapped_stringdb.csv", sep = "\t") # file separated by tabs despite using csv
aal_mapped_protein_ids_stringdb <- read.csv("databases/03-enrichment/aal-mapped_stringdb.csv", sep = "\t") # file separated by tabs despite using csv
aae_down_mapped_protein_ids_stringdb <- read.csv("databases/03-enrichment/aae-down-mapped_stringdb.tsv", sep = "\t")

# ==== FUNCTION TO EXTRACT PROTEIN IDS FROM ENRICHED PROCESSES ====
# This function takes a dataframe of enriched processes and extracts the protein ids from the 'genes' and 'pathway_genes' columns.

expand_genes_to_rows_stringdb <- function(df) {
  # split both protein ID and label columns
  df %>%
    mutate(across(c(matching_proteins_id_network, matching_proteins_labels_network), as.character)) %>%
    separate_rows(matching_proteins_id_network, matching_proteins_labels_network, sep = ",")
}

## Apply function to all dataframes
# Per miRNA
expanded_per_mirna_stringdb <- expand_genes_to_rows_stringdb(important_per_mirna_stringdb)

# Venny
expanded_venny_stringdb <- expand_genes_to_rows_stringdb(important_venny_stringdb) # No enrichment results

# All
expanded_all_stringdb <- expand_genes_to_rows_stringdb(important_all_stringdb)

# Aae down-regulated common
# Per miRNA
expanded_aae_per_mirna_down_stringdb <- expand_genes_to_rows_stringdb(aae_per_mirna_down)

# All
expanded_aae_all_down_stringdb <- expand_genes_to_rows_stringdb(aae_all_down)

# ==== FIX AND FUSE MAPPED PROTEIN IDS ====
## Add a species column to each mapped protein ids dataframe
# For stringdb
aae_mapped_protein_ids_stringdb <- aae_mapped_protein_ids_stringdb |>
  mutate(species = "Aedes aegypti")
aal_mapped_protein_ids_stringdb <- aal_mapped_protein_ids_stringdb |>
  mutate(species = "Aedes albopictus")
aae_down_mapped_protein_ids_stringdb <- aae_down_mapped_protein_ids_stringdb |>
  mutate(species = "Aedes aegypti")

## Combine the mapped protein ids dataframes into one
## For stringdb
mapped_protein_ids_stringdb <- bind_rows(
  aae_mapped_protein_ids_stringdb,
  aal_mapped_protein_ids_stringdb
)

# ==== FUNCTION TO MATCH PROTEIN IDS TO NAMES ====
# This function takes a dataframe of protein ids and matches them to their names using the imported mapped protein ids from stringdb.
# StringDB
map_stringdb_annotations <- function(df, mapping_df = mapped_protein_ids_stringdb) {
  df %>%
    left_join(
      mapping_df %>%
        select(matching_proteins_id_network = stringId, annotation = annotation, species),
      by = c("matching_proteins_id_network", "species"),
      relationship = "many-to-many" # expects multiple matches
    ) %>%
    # Replace empty strings with NA (for consistency)
    mutate(across(where(is.character), ~ na_if(.x, ""))) %>%
    # Reorder columns so Description is right after gene_id
    relocate(annotation, .after = matching_proteins_labels_network) %>%
    # Remove duplicates based on all columns EXCEPT matching_proteins_id_network
    distinct(across(-matching_proteins_id_network), .keep_all = TRUE)
}

# ==== APPLY MAPPING FUNCTIONS ====
## For stringdb
full_expanded_per_mirna_stringdb <- map_stringdb_annotations(expanded_per_mirna_stringdb, mapped_protein_ids_stringdb)

# This one won't run because none of the enriched processes were of interest (category_of_interest = NA; too general for immune, neuro, etc)
# full_expanded_venny_stringdb <- map_stringdb_annotations(expanded_venny_stringdb, mapped_protein_ids_stringdb)

full_expanded_all_stringdb <- map_stringdb_annotations(expanded_all_stringdb, mapped_protein_ids_stringdb)

# aae down-regulated common
# Per miRNA
full_expanded_per_mirna_down_stringdb <- map_stringdb_annotations(expanded_aae_per_mirna_down_stringdb, aae_down_mapped_protein_ids_stringdb)

# All
full_expanded_all_down_stringdb <- map_stringdb_annotations(expanded_aae_all_down_stringdb, aae_down_mapped_protein_ids_stringdb)

# ==== STRIP TAX ID FROM UNIPROT IDs =====


# ==== SAVE RESULTS ====
# Save the full expanded dataframes with protein names and descriptions
# StringDB
write.csv(full_expanded_per_mirna_stringdb, "results/02-enrichment/04-enrich-full-anotation/full-expanded-per-mirna-stringdb.csv", row.names = FALSE)

write.csv(full_expanded_all_stringdb, "results/02-enrichment/04-enrich-full-anotation/full-expanded-all-stringdb.csv", row.names = FALSE)

# ==== FILTER IMMUNE AND OTHER PROCESSES ====
# all
immune_expanded_all_stringdb <- full_expanded_all_stringdb |>
  filter(category_of_interest == "immune" | category_of_interest == "other")

# per-mirna
immune_expanded_per_mirna_stringdb <- full_expanded_per_mirna_stringdb |>
  filter(category_of_interest == "immune" | category_of_interest == "other")

# ==== SAVE FINAL IMMUNE DATASET ====
# all
write.csv(immune_expanded_all_stringdb, "results/02-enrichment/04-enrich-full-anotation/immune-expanded-all-stringdb.csv", row.names = FALSE)

# per-mirna
write.csv(immune_expanded_per_mirna_stringdb, "results/02-enrichment/04-enrich-full-anotation/immune-expanded-per-mirna-stringdb.csv", row.names = FALSE)
