# ~~~~ CYTOSCAPE PPI IMPORT ~~~~~
# This script prepares string ppi analysis export data and formats it for cytoscape by adding the mapped protein names of the nodes for better visialization.
# This script will take interaction files from STRINGDB where the PPI analysis was significant and add the following columns:
# - After node2_string_id: it will add `node1_uniprot_id` and `node2_uniprot_id` with only uniprot ids (not the string taxon ID)
# `protein_name1` and `protein_name2`: eggnog mapper name.
#
# Then, based on the edge table, we will create a node table with the following columns:
# - string_id: STRINGDB identifier (taxonID.uniprotID)
# - original_id: original protein ID from our dataset
# - uniprot_id: uniprot ID
# - protein_name: eggnog mapper name
# This final table will be imported as a node table in cytoscape after using stringApp to import the edge table.

# ==== IMPORT LIBRARIES ====
library(dplyr)
library(tidyr)
library(stringr)
library(tidylog, warn.conflicts = FALSE)

# ==== IMPORT DATA ====
# Import node data
# Aedes aegypti
aae_edge <- read.csv("results/04-ppi-network/aae-all/aae_string_interactions_short.tsv", sep = "\t")

aae_common_all_edge <- read.csv("results/04-ppi-network/aae-common-all/aae_common_string_interactions_short.tsv", sep = "\t")

aae_mir_2945_3p_edge <- read.csv("results/04-ppi-network/aae-mir-2945-3p/string_interactions_short.tsv", sep = "\t")

# Aedes albopictus
aal_edge <- read.csv("results/04-ppi-network/aal-all/aal_string_interactions_short.tsv", sep = "\t")

## protein names + uniprot ids
## This dataset has both species
prot_names_all <- read.csv("results/02-enrichment/07-tidying-results/03-final-enrichment/prot_final_exp_ann_all.csv")

prot_names_per_mirna <- read.csv("results/02-enrichment/07-tidying-results/03-final-enrichment/prot_final_exp_ann_per_mirna.csv")

# ==== FILTER DATA AND REMOVE DUPLICATES ====
## Filter by species
## All
aae_prot_names_all <- prot_names_all %>% dplyr::filter(species == "Aedes aegypti")
aal_prot_names_all <- prot_names_all %>% dplyr::filter(species == "Aedes albopictus")

## Per-miRNA
aae_prot_names_per_mirna <- prot_names_per_mirna %>%
  dplyr::filter(species == "Aedes aegypti")

# First, deduplicate the protein names dataframe by keeping the first occurrence of each uniprot_id
aae_all_prot_names_unique <- aae_prot_names_all %>%
  distinct(uniprot_id, .keep_all = TRUE)

aal_all_prot_names_unique <- aal_prot_names_all %>%
  distinct(uniprot_id, .keep_all = TRUE)

aae_per_mirna_prot_names_unique <- aae_prot_names_per_mirna %>%
  distinct(uniprot_id, .keep_all = TRUE)

# Create identifier column in the format used in STRINGDB (i.e., taxonID.uniprotID)
aae_all_prot_names_unique2 <- aae_all_prot_names_unique %>%
  mutate(identifier = paste0(taxon_id, ".", uniprot_id))

aal_all_prot_names_unique2 <- aal_all_prot_names_unique %>%
  mutate(identifier = paste0(taxon_id, ".", uniprot_id))

aae_per_mirna_prot_names_unique2 <- aae_per_mirna_prot_names_unique %>%
  mutate(identifier = paste0(taxon_id, ".", uniprot_id))

# ==== ADD COLUMNS TO EDGE DATA ====
## Aedes aegypti all
aae_edge_final <- aae_edge %>%
  # Join with deduplicated protein names to get uniprot IDs for node1_string_id
  left_join(
    aae_all_prot_names_unique2 %>% select(identifier, uniprot_id),
    by = c("node1_string_id" = "identifier")
  ) %>%
  rename(node1_uniprot_id = uniprot_id) %>%
  # Join with deduplicated protein names to get uniprot IDs for node2_string_id
  left_join(
    aae_all_prot_names_unique2 %>% select(identifier, uniprot_id),
    by = c("node2_string_id" = "identifier")
  ) %>%
  rename(node2_uniprot_id = uniprot_id) %>%
  # Join with deduplicated protein names for node1 (using node1_uniprot_id)
  left_join(
    aae_all_prot_names_unique2 %>% select(uniprot_id, protein_name),
    by = c("node1_uniprot_id" = "uniprot_id")
  ) %>%
  rename(protein_name_1 = protein_name) %>%
  # Join with deduplicated protein names for node2 (using node2_uniprot_id)
  left_join(
    aae_all_prot_names_unique2 %>% select(uniprot_id, protein_name),
    by = c("node2_uniprot_id" = "uniprot_id")
  ) %>%
  rename(protein_name_2 = protein_name) %>%
  # Move the new columns to the correct position (after node2_string_id)
  select(
    X.node1, node2, node1_string_id, node2_string_id,
    node1_uniprot_id, node2_uniprot_id, protein_name_1, protein_name_2,
    everything()
  )

## Aedes aegypti common all
aae_common_edge_final <- aae_common_all_edge %>%
  # Join with deduplicated protein names to get uniprot IDs for node1_string_id
  left_join(
    aae_all_prot_names_unique2 %>% select(identifier, uniprot_id),
    by = c("node1_string_id" = "identifier")
  ) %>%
  rename(node1_uniprot_id = uniprot_id) %>%
  # Join with deduplicated protein names to get uniprot IDs for node2_string_id
  left_join(
    aae_all_prot_names_unique2 %>% select(identifier, uniprot_id),
    by = c("node2_string_id" = "identifier")
  ) %>%
  rename(node2_uniprot_id = uniprot_id) %>%
  # Join with deduplicated protein names for node1 (using node1_uniprot_id)
  left_join(
    aae_all_prot_names_unique2 %>% select(uniprot_id, protein_name),
    by = c("node1_uniprot_id" = "uniprot_id")
  ) %>%
  rename(protein_name_1 = protein_name) %>%
  # Join with deduplicated protein names for node2 (using node2_uniprot_id)
  left_join(
    aae_all_prot_names_unique2 %>% select(uniprot_id, protein_name),
    by = c("node2_uniprot_id" = "uniprot_id")
  ) %>%
  rename(protein_name_2 = protein_name) %>%
  # Move the new columns to the correct position (after node2_string_id)
  select(
    X.node1, node2, node1_string_id, node2_string_id,
    node1_uniprot_id, node2_uniprot_id, protein_name_1, protein_name_2,
    everything()
  )

## aae-miR-2945-3p
aae_mir_2945_3p_edge_final <- aae_mir_2945_3p_edge %>%
  # Join with deduplicated protein names to get uniprot IDs for node1_string_id
  left_join(
    aae_per_mirna_prot_names_unique2 %>% select(identifier, uniprot_id),
    by = c("node1_string_id" = "identifier")
  ) %>%
  rename(node1_uniprot_id = uniprot_id) %>%
  # Join with deduplicated protein names to get uniprot IDs for node2_string_id
  left_join(
    aae_per_mirna_prot_names_unique2 %>% select(identifier, uniprot_id),
    by = c("node2_string_id" = "identifier")
  ) %>%
  rename(node2_uniprot_id = uniprot_id) %>%
  # Join with deduplicated protein names for node1 (using node1_uniprot_id)
  left_join(
    aae_per_mirna_prot_names_unique2 %>% select(uniprot_id, protein_name),
    by = c("node1_uniprot_id" = "uniprot_id")
  ) %>%
  rename(protein_name_1 = protein_name) %>%
  # Join with deduplicated protein names for node2 (using node2_uniprot_id)
  left_join(
    aae_per_mirna_prot_names_unique2 %>% select(uniprot_id, protein_name),
    by = c("node2_uniprot_id" = "uniprot_id")
  ) %>%
  rename(protein_name_2 = protein_name) %>%
  # Move the new columns to the correct position (after node2_string_id)
  select(
    X.node1, node2, node1_string_id, node2_string_id,
    node1_uniprot_id, node2_uniprot_id, protein_name_1, protein_name_2,
    everything()
  )

## Aedes albopictus all
aal_edge_final <- aal_edge %>%
  # Join with deduplicated protein names to get uniprot IDs for node1_string_id
  left_join(
    aae_all_prot_names_unique2 %>% select(identifier, uniprot_id),
    by = c("node1_string_id" = "identifier")
  ) %>%
  rename(node1_uniprot_id = uniprot_id) %>%
  # Join with deduplicated protein names to get uniprot IDs for node2_string_id
  left_join(
    aal_all_prot_names_unique2 %>% select(identifier, uniprot_id),
    by = c("node2_string_id" = "identifier")
  ) %>%
  rename(node2_uniprot_id = uniprot_id) %>%
  # Join with deduplicated protein names for node1 (using node1_uniprot_id)
  left_join(
    aal_all_prot_names_unique2 %>% select(uniprot_id, protein_name),
    by = c("node1_uniprot_id" = "uniprot_id")
  ) %>%
  rename(protein_name_1 = protein_name) %>%
  # Join with deduplicated protein names for node2 (using node2_uniprot_id)
  left_join(
    aal_all_prot_names_unique2 %>% select(uniprot_id, protein_name),
    by = c("node2_uniprot_id" = "uniprot_id")
  ) %>%
  rename(protein_name_2 = protein_name) %>%
  # Move the new columns to the correct position (after node2_string_id)
  select(
    X.node1, node2, node1_string_id, node2_string_id,
    node1_uniprot_id, node2_uniprot_id, protein_name_1, protein_name_2,
    everything()
  )

## ==== ADD NAMES TO NAs ====
# After joining, some protein names may be NA if there was no match in the deduplicated protein names data.
# Aedes aegypti all
aae_edge_final2 <- aae_edge_final %>%
  mutate(
    # Extract uniprot_id from string_id by removing taxon_id prefix
    node1_uniprot_id = if_else(
      is.na(node1_uniprot_id),
      str_remove(node1_string_id, "^[0-9]+\\."),
      node1_uniprot_id
    ),
    node2_uniprot_id = if_else(
      is.na(node2_uniprot_id),
      str_remove(node2_string_id, "^[0-9]+\\."),
      node2_uniprot_id
    ),
    # Fill protein names with uniprot_id if NA
    protein_name_1 = if_else(
      is.na(protein_name_1),
      node1_uniprot_id,
      protein_name_1
    ),
    protein_name_2 = if_else(
      is.na(protein_name_2),
      node2_uniprot_id,
      protein_name_2
    )
  )

# Aedes aegypti common all
aae_common_edge_final2 <- aae_common_edge_final %>%
  mutate(
    # Extract uniprot_id from string_id by removing taxon_id prefix
    node1_uniprot_id = if_else(
      is.na(node1_uniprot_id),
      str_remove(node1_string_id, "^[0-9]+\\."),
      node1_uniprot_id
    ),
    node2_uniprot_id = if_else(
      is.na(node2_uniprot_id),
      str_remove(node2_string_id, "^[0-9]+\\."),
      node2_uniprot_id
    ),
    # Fill protein names with uniprot_id if NA
    protein_name_1 = if_else(
      is.na(protein_name_1),
      node1_uniprot_id,
      protein_name_1
    ),
    protein_name_2 = if_else(
      is.na(protein_name_2),
      node2_uniprot_id,
      protein_name_2
    )
  )

# aae-mir-2945-3p
aae_mir_2945_3p_edge_final2 <- aae_mir_2945_3p_edge_final %>%
  mutate(
    # Extract uniprot_id from string_id by removing taxon_id prefix
    node1_uniprot_id = if_else(
      is.na(node1_uniprot_id),
      str_remove(node1_string_id, "^[0-9]+\\."),
      node1_uniprot_id
    ),
    node2_uniprot_id = if_else(
      is.na(node2_uniprot_id),
      str_remove(node2_string_id, "^[0-9]+\\."),
      node2_uniprot_id
    ),
    # Fill protein names with uniprot_id if NA
    protein_name_1 = if_else(
      is.na(protein_name_1),
      node1_uniprot_id,
      protein_name_1
    ),
    protein_name_2 = if_else(
      is.na(protein_name_2),
      node2_uniprot_id,
      protein_name_2
    )
  )

# Aedes albopictus
aal_edge_final2 <- aal_edge_final %>%
  mutate(
    # Extract uniprot_id from string_id by removing taxon_id prefix
    node1_uniprot_id = if_else(
      is.na(node1_uniprot_id),
      str_remove(node1_string_id, "^[0-9]+\\."),
      node1_uniprot_id
    ),
    node2_uniprot_id = if_else(
      is.na(node2_uniprot_id),
      str_remove(node2_string_id, "^[0-9]+\\."),
      node2_uniprot_id
    ),
    # Fill protein names with uniprot_id if NA
    protein_name_1 = if_else(
      is.na(protein_name_1),
      node1_uniprot_id,
      protein_name_1
    ),
    protein_name_2 = if_else(
      is.na(protein_name_2),
      node2_uniprot_id,
      protein_name_2
    )
  )

# ==== CREATE NODE TABLE ====
# Create node table from your edge table
# Aedes aegypti all
aae_all_node_table <- bind_rows(
  # Get node1 information
  aae_edge_final2 %>%
    select(
      string_id = node1_string_id,
      original_id = X.node1,
      uniprot_id = node1_uniprot_id,
      protein_name = protein_name_1
    ),

  # Get node2 information
  aae_edge_final2 %>%
    select(
      string_id = node2_string_id,
      original_id = node2,
      uniprot_id = node2_uniprot_id,
      protein_name = protein_name_2
    )
) %>%
  # Remove duplicates (keep first occurrence)
  # distinct(string_id, .keep_all = TRUE) %>%
  arrange(string_id)

# Aedes aegypti common all
aae_common_all_node_table <- bind_rows(
  # Get node1 information
  aae_common_edge_final2 %>%
    select(
      string_id = node1_string_id,
      original_id = X.node1,
      uniprot_id = node1_uniprot_id,
      protein_name = protein_name_1
    ),

  # Get node2 information
  aae_common_edge_final2 %>%
    select(
      string_id = node2_string_id,
      original_id = node2,
      uniprot_id = node2_uniprot_id,
      protein_name = protein_name_2
    )
) %>%
  # Remove duplicates (keep first occurrence)
  # distinct(string_id, .keep_all = TRUE) %>%
  arrange(string_id)

# aae-mir-2945-3p
aae_mir_2945_3p_node_table <- bind_rows(
  # Get node1 information
  aae_mir_2945_3p_edge_final2 %>%
    select(
      string_id = node1_string_id,
      original_id = X.node1,
      uniprot_id = node1_uniprot_id,
      protein_name = protein_name_1
    ),

  # Get node2 information
  aae_mir_2945_3p_edge_final2 %>%
    select(
      string_id = node2_string_id,
      original_id = node2,
      uniprot_id = node2_uniprot_id,
      protein_name = protein_name_2
    )
) %>%
  # Remove duplicates (keep first occurrence)
  # distinct(string_id, .keep_all = TRUE) %>%
  arrange(string_id)

# Aedes albopciptus all
aal_node_table <- bind_rows(
  # Get node1 information
  aal_edge_final2 %>%
    select(
      string_id = node1_string_id,
      original_id = X.node1,
      uniprot_id = node1_uniprot_id,
      protein_name = protein_name_1
    ),

  # Get node2 information
  aal_edge_final2 %>%
    select(
      string_id = node2_string_id,
      original_id = node2,
      uniprot_id = node2_uniprot_id,
      protein_name = protein_name_2
    )
) %>%
  # Remove duplicates (keep first occurrence)
  # distinct(string_id, .keep_all = TRUE) %>%
  arrange(string_id)

# ==== SAVE FINAL DATA ====
## Aedes aegypti all
## Node table
write.csv(aae_all_node_table, "results/04-ppi-network/aae-all/output/aae_node_table.csv", row.names = FALSE)

## Aedes aegypti common all
write.csv(aae_common_all_node_table, "results/04-ppi-network/aae-common-all/output/aae_common_node_table.csv", row.names = FALSE)

## aae-mir-2945-3p
write.csv(aae_mir_2945_3p_node_table, "results/04-ppi-network/aae-mir-2945-3p/output/aae_mir_2945_3p_node_table.csv", row.names = FALSE)

## Aedes albopictus all
## Node table
write.csv(aal_node_table, "results/04-ppi-network/aal-all/output/aal_node_table.csv", row.names = FALSE)
