# ~~~~ ORTHOSCAPE IMPORT ~~~~~
# This script prepares string ppi analysis export data and formats it for cytoscape's plugin orthoscape analysis as it requires kegg ids for all nodes.
# This script will take aedes_aegypti_STRING.tsv and aedes_albopictus_STRING.tsv and add the following columns:
# - After node2_string_id, add `node1_uniprot_id` and `node2_uniprot_id` with only uniprot ids (not the string taxon ID)
# - `id1` and `id2`: kegg ids of node 1 and 2
# `protein_name1` and `protein_name2`: eggnog mapper name.
#
# This script will take `aae_sring_node_degrees.tsv` and `aal_string_node_degrees.tsv` and add the following columns:
# - Between `Identifier` and `node_degree`, add `id` (kegg ids) and `protein_name` (eggnog mapper)
# Finally, it will remove nodes without kegg ids in both files for both species
#

# ==== IMPORT LIBRARIES ====
library(dplyr)
library(tidyr)
library(tidylog, warn.conflicts = FALSE)

# ==== IMPORT DATA ====
# Import node data
aae_edge <- read.csv("results/03-taxonomic-comparison/02-orthoscape-import/aae/aedes_aegypti_STRING.tsv", sep = "\t")
aal_edge <- read.csv("results/03-taxonomic-comparison/02-orthoscape-import/aal/aedes_albopictus_STRING.tsv", sep = "\t")

# Import node degree data
aae_degree <- read.csv("results/03-taxonomic-comparison/02-orthoscape-import/aae/aae_string_node_degrees.tsv", sep = "\t")
aal_degree <- read.csv("results/03-taxonomic-comparison/02-orthoscape-import/aal/aal_string_node_degrees.tsv", sep = "\t")

# Import data that have the kegg ids, uniprot ids and protein names (eggnog mapper)
## kegg ids + uniprot ids
aae_kegg_uniprot <- read.csv("results/03-taxonomic-comparison/01-add-kegg-ids/03-final_kegg_ids/aae_keggids.csv")
aal_kegg_uniprot <- read.csv("results/03-taxonomic-comparison/01-add-kegg-ids/03-final_kegg_ids/aal_keggids.csv")

## protein names
## This dataset has both species
prot_names <- read.csv("results/04-heatmap/final_ann_all.csv")

## Filter by species
aae_prot_names <- prot_names %>% filter(species == "Aedes aegypti")
aal_prot_names <- prot_names %>% filter(species == "Aedes albopictus")

# First, deduplicate the protein names dataframe by keeping the first occurrence of each uniprot_id
aae_prot_names_unique <- aae_prot_names %>%
  distinct(uniprot_id, .keep_all = TRUE)

aal_prot_names_unique <- aal_prot_names %>%
  distinct(uniprot_id, .keep_all = TRUE)

# ==== ADD COLUMNS TO EDGE DATA ====
## Aedes aegypti
aae_edge_ortho1 <- aae_edge %>%
  # Join with kegg_uniprot to get uniprot IDs for node1_string_id
  left_join(
    aae_kegg_uniprot %>% select(identifier, mapped_id),
    by = c("node1_string_id" = "identifier")
  ) %>%
  rename(node1_uniprot_id = mapped_id) %>%
  # Join with kegg_uniprot to get uniprot IDs for node2_string_id
  left_join(
    aae_kegg_uniprot %>% select(identifier, mapped_id),
    by = c("node2_string_id" = "identifier")
  ) %>%
  rename(node2_uniprot_id = mapped_id) %>%
  # Join with kegg_uniprot to get kegg IDs for node1
  left_join(
    aae_kegg_uniprot %>% select(identifier, kegg_id),
    by = c("node1_string_id" = "identifier")
  ) %>%
  rename(id1 = kegg_id) %>%
  # Join with kegg_uniprot to get kegg IDs for node2
  left_join(
    aae_kegg_uniprot %>% select(identifier, kegg_id),
    by = c("node2_string_id" = "identifier")
  ) %>%
  rename(id2 = kegg_id) %>%
  # Join with deduplicated protein names for node1 (using node1_uniprot_id)
  left_join(
    aae_prot_names_unique %>% select(uniprot_id, protein_name),
    by = c("node1_uniprot_id" = "uniprot_id")
  ) %>%
  rename(protein_name_1 = protein_name) %>%
  # Join with deduplicated protein names for node2 (using node2_uniprot_id)
  left_join(
    aae_prot_names_unique %>% select(uniprot_id, protein_name),
    by = c("node2_uniprot_id" = "uniprot_id")
  ) %>%
  rename(protein_name_2 = protein_name) %>%
  # Move the new columns to the correct position (after node2_string_id)
  select(
    X.node1, node2, node1_string_id, node2_string_id,
    node1_uniprot_id, node2_uniprot_id, id1, id2, protein_name_1, protein_name_2,
    everything()
  )

## Aedes albopictus
aal_edge_ortho1 <- aal_edge %>%
  # Join with kegg_uniprot to get uniprot IDs for node1_string_id
  left_join(
    aal_kegg_uniprot %>% select(identifier, mapped_id),
    by = c("node1_string_id" = "identifier")
  ) %>%
  rename(node1_uniprot_id = mapped_id) %>%
  # Join with kegg_uniprot to get uniprot IDs for node2_string_id
  left_join(
    aal_kegg_uniprot %>% select(identifier, mapped_id),
    by = c("node2_string_id" = "identifier")
  ) %>%
  rename(node2_uniprot_id = mapped_id) %>%
  # Join with kegg_uniprot to get kegg IDs for node1
  left_join(
    aal_kegg_uniprot %>% select(identifier, kegg_id),
    by = c("node1_string_id" = "identifier")
  ) %>%
  rename(id1 = kegg_id) %>%
  # Join with kegg_uniprot to get kegg IDs for node2
  left_join(
    aal_kegg_uniprot %>% select(identifier, kegg_id),
    by = c("node2_string_id" = "identifier")
  ) %>%
  rename(id2 = kegg_id) %>%
  # Join with deduplicated protein names for node1 (using node1_uniprot_id)
  left_join(
    aal_prot_names_unique %>% select(uniprot_id, protein_name),
    by = c("node1_uniprot_id" = "uniprot_id")
  ) %>%
  rename(protein_name_1 = protein_name) %>%
  # Join with deduplicated protein names for node2 (using node2_uniprot_id)
  left_join(
    aal_prot_names_unique %>% select(uniprot_id, protein_name),
    by = c("node2_uniprot_id" = "uniprot_id")
  ) %>%
  rename(protein_name_2 = protein_name) %>%
  # Move the new columns to the correct position (after node2_string_id)
  select(
    X.node1, node2, node1_string_id, node2_string_id,
    node1_uniprot_id, node2_uniprot_id, id1, id2, protein_name_1, protein_name_2,
    everything()
  )

# ==== ADD COLUMNS TO NODE DEGREE DATA ====
## Aedes aegypti
aae_degree_ortho1 <- aae_degree %>%
  # Join with kegg_uniprot to get uniprot IDs for identifier
  left_join(
    aae_kegg_uniprot %>% select(identifier, mapped_id),
    by = "identifier"
  ) %>%
  rename(uniprot_id = mapped_id) %>%
  # Join with kegg_uniprot to get kegg IDs
  left_join(
    aae_kegg_uniprot %>% select(identifier, kegg_id),
    by = "identifier"
  ) %>%
  rename(id = kegg_id) %>%
  # Join with deduplicated protein names for node1 (using node1_uniprot_id)
  left_join(
    aae_prot_names_unique %>% select(uniprot_id, protein_name),
    by = "uniprot_id"
  ) %>%
  # Move the new columns to the correct position (after node2_string_id)
  select(
    X.node, identifier, uniprot_id, id, protein_name,
    everything()
  )

## Aedes albopictus
aal_degree_ortho1 <- aal_degree %>%
  # Join with kegg_uniprot to get uniprot IDs for identifier
  left_join(
    aal_kegg_uniprot %>% select(identifier, mapped_id),
    by = "identifier"
  ) %>%
  rename(uniprot_id = mapped_id) %>%
  # Join with kegg_uniprot to get kegg IDs
  left_join(
    aal_kegg_uniprot %>% select(identifier, kegg_id),
    by = "identifier"
  ) %>%
  rename(id = kegg_id) %>%
  # Join with deduplicated protein names for node1 (using node1_uniprot_id)
  left_join(
    aal_prot_names_unique %>% select(uniprot_id, protein_name),
    by = "uniprot_id"
  ) %>%
  # Move the new columns to the correct position (after node2_string_id)
  select(
    X.node, identifier, uniprot_id, id, protein_name,
    everything()
  )

# ==== REMOVE NODES WITHOUT KEGG ID ====
# Uses tidyr to remove rows when id1 OR id2 is an NA value.
## Aedes aegypti
## For Edge data
aae_edge_ortho2 <- aae_edge_ortho1 %>% drop_na(id1, id2) %>%
  # If there are NA values on protein_name_1 or protein_name_2
  # then copy the `node1_uniprot_id` and `node2_uniprot_id`, respectively
  mutate(
    protein_name_1 = ifelse(is.na(protein_name_1), node1_uniprot_id, protein_name_1),
    protein_name_2 = ifelse(is.na(protein_name_2), node2_uniprot_id, protein_name_2)
  )

## For Degree data
aae_degree_ortho2 <- aae_degree_ortho1 %>% drop_na(id) %>%
  # If there are NA values on protein_name
  # then copy the `uniprot_id` value
  mutate(
    protein_name = ifelse(is.na(protein_name), uniprot_id, protein_name)
  )

## Aedes albopictus
## For Edge data
aal_edge_ortho2 <- aal_edge_ortho1 %>%
  drop_na(id1, id2) %>%
  # If there are NA values on protein_name_1 or protein_name_2
  # then copy the `node1_uniprot_id` and `node2_uniprot_id`, respectively
  mutate(
    protein_name_1 = ifelse(is.na(protein_name_1), node1_uniprot_id, protein_name_1),
    protein_name_2 = ifelse(is.na(protein_name_2), node2_uniprot_id, protein_name_2)
  )

## For degree data
aal_degree_ortho2 <- aal_degree_ortho1 %>% drop_na(id) %>%
  # If there are NA values on protein_name
  # then copy the `uniprot_id` value
  mutate(
    protein_name = ifelse(is.na(protein_name), uniprot_id, protein_name)
  )

# ==== SAVE FINAL DATA ====
## Aedes aegypti
## Edge table
write.csv(aae_edge_ortho2, "results/03-taxonomic-comparison/02-orthoscape-import/aae/aae_edge_ortho.csv", row.names = FALSE)

## Degree table
write.csv(aae_degree_ortho2, "results/03-taxonomic-comparison/02-orthoscape-import/aae/aae_degree_ortho.csv", row.names = FALSE)

## Aedes albopictus
## Edge table
write.csv(aal_edge_ortho2, "results/03-taxonomic-comparison/02-orthoscape-import/aal/aal_edge_ortho.csv", row.names = FALSE)

## Degree table
write.csv(aal_degree_ortho2, "results/03-taxonomic-comparison/02-orthoscape-import/aal/aal_degree_ortho.csv", row.names = FALSE)
