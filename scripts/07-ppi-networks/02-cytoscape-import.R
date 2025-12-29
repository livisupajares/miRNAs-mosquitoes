# ~~~~ CYTOSCAPE PPI IMPORT ~~~~~
# This script prepares string ppi analysis export data and formats it for cytoscape by adding the mapped protein names of the nodes for better visialization.
# This script will take interaction files from STRINGDB where the PPI analysis was significant and add the following columns:
# - After node2_string_id: it will add `node1_uniprot_id` and `node2_uniprot_id` with only uniprot ids (not the string taxon ID)
# `protein_name1` and `protein_name2`: eggnog mapper name.
#
# This script will take node degree files from STRINGDB where the PPI analysis was significant, and add the following columns:
# - Between `Identifier` and `node_degree`: it will add the `protein_name` (eggnog mapper)
# TODO: After seeing the results after importing into cytoscape, remove the nodes that map to the same protein name to reduce redundancy.

# ==== IMPORT LIBRARIES ====
library(dplyr)
library(tidyr)
library(tidylog, warn.conflicts = FALSE)

# ==== IMPORT DATA ====
# Import node data
# Aedes aegypti
aae_edge <- read.csv("results/04-ppi-network/aae-all/aae_string_interactions_short.tsv", sep = "\t")

aae_common_all_edge <- read.csv("results/04-ppi-network/aae-common-all/aae_common_string_interactions_short.tsv", sep = "\t")

aae_mir_2945_3p_edge <- read.csv("results/04-ppi-network/aae-mir-2945-3p/string_interactions_short.tsv", sep = "\t")

# Aedes albopictus
aal_edge <- read.csv("results/04-ppi-network/aal-all/aal_string_interactions_short.tsv", sep = "\t")

# Import node degree data
# aae_degree <- read.csv("results/06-taxonomic-comparison/02-orthoscape-import/aae/aae_string_node_degrees.tsv", sep = "\t")
# aal_degree <- read.csv("results/06-taxonomic-comparison/02-orthoscape-import/aal/aal_string_node_degrees.tsv", sep = "\t")

## Import data that have uniprot ids and protein names (eggnog mapper)

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
## Aedes aegypti
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

## Aedes aegypti
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

# ==== ADD COLUMNS TO NODE DEGREE DATA ====
## Aedes aegypti
# aae_degree_ortho1 <- aae_degree %>%
#   # Join with kegg_uniprot to get uniprot IDs for identifier
#   left_join(
#     aae_kegg_uniprot %>% select(identifier, mapped_id),
#     by = "identifier"
#   ) %>%
#   rename(uniprot_id = mapped_id) %>%
#   # Join with kegg_uniprot to get kegg IDs
#   left_join(
#     aae_kegg_uniprot %>% select(identifier, kegg_id),
#     by = "identifier"
#   ) %>%
#   rename(id = kegg_id) %>%
#   # Join with deduplicated protein names for node1 (using node1_uniprot_id)
#   left_join(
#     aae_prot_names_unique %>% select(uniprot_id, protein_name),
#     by = "uniprot_id"
#   ) %>%
#   # Move the new columns to the correct position (after node2_string_id)
#   select(
#     X.node, identifier, uniprot_id, id, protein_name,
#     everything()
#   )
#
# ## Aedes albopictus
# aal_degree_ortho1 <- aal_degree %>%
#   # Join with kegg_uniprot to get uniprot IDs for identifier
#   left_join(
#     aal_kegg_uniprot %>% select(identifier, mapped_id),
#     by = "identifier"
#   ) %>%
#   rename(uniprot_id = mapped_id) %>%
#   # Join with kegg_uniprot to get kegg IDs
#   left_join(
#     aal_kegg_uniprot %>% select(identifier, kegg_id),
#     by = "identifier"
#   ) %>%
#   rename(id = kegg_id) %>%
#   # Join with deduplicated protein names for node1 (using node1_uniprot_id)
#   left_join(
#     aal_prot_names_unique %>% select(uniprot_id, protein_name),
#     by = "uniprot_id"
#   ) %>%
#   # Move the new columns to the correct position (after node2_string_id)
#   select(
#     X.node, identifier, uniprot_id, id, protein_name,
#     everything()
#   )

# ==== SAVE FINAL DATA ====
## Aedes aegypti
## Edge table
write.csv(aae_edge_final, "results/04-ppi-network/aae-all/output/aae_string_interactions_short.csv", row.names = FALSE)

## Degree table
# write.csv(aae_degree_ortho2, "results/03-taxonomic-comparison/02-orthoscape-import/aae/aae_degree_ortho.csv", row.names = FALSE)

## Aedes albopictus
## Edge table
write.csv(aal_edge_ortho2, "results/03-taxonomic-comparison/02-orthoscape-import/aal/aal_edge_ortho.csv", row.names = FALSE)

## Degree table
# write.csv(aal_degree_ortho2, "results/03-taxonomic-comparison/02-orthoscape-import/aal/aal_degree_ortho.csv", row.names = FALSE)
