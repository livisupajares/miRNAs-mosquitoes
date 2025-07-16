# ~~~~~ PROTEINS OF ENRICHED PROCESES ~~~~~~
# This script splits the genes and pathway_genes into a list of protein ids for each enriched process.
# Then each list is saved into a dataframe with the process name and the list of protein ids.
# Then, the list of protein ids is matched to their names and/or descriptions with imported dataframes of mapped protein ids from ensembl metazoa or stringdb.

# ==== Load libraries ====
library(dplyr)
library(tidyr)

# ==== IMPORT DATA ====
## Import enriched processes data
# Per miRNA
important_per_mirna_shinygo <- read.csv("results/01-enrichment/03-enrichments-important-process/important-per-mirna-shinygo.csv")
important_per_mirna_stringdb <- read.csv("results/01-enrichment/03-enrichments-important-process/important-per-mirna-stringdb.csv")

# Venny
important_venny_shinygo <- read.csv("results/01-enrichment/03-enrichments-important-process/important-venny-shinygo.csv")
important_venny_stringdb <- read.csv("results/01-enrichment/03-enrichments-important-process/important-venny-stringdb.csv")

# All
important_all_shinygo <- read.csv("results/01-enrichment/03-enrichments-important-process/important-all-shinygo.csv")
important_all_stringdb <- read.csv("results/01-enrichment/03-enrichments-important-process/important-all-stringdb.csv")

# Import mapped protein ids from ensembl metazoa
aae_mapped_protein_ids_ensembl <- read.csv("databases/03-enrichment/aae-mapped_shinygo_metazoa.csv")
aal_mapped_protein_ids_ensembl <- read.csv("databases/03-enrichment/aal-mapped_shinygo_metazoa.csv")

# Import mapped protein ids from stringdb
aae_mapped_protein_ids_stringdb <- read.csv("databases/03-enrichment/aae-mapped_stringdb.csv")
aal_mapped_protein_ids_stringdb <- read.csv("databases/03-enrichment/aal-mapped_stringdb.csv")

# ==== FUNCTION TO EXTRACT PROTEIN IDS FROM ENRICHED PROCESSES ====
# This function takes a dataframe of enriched processes and extracts the protein ids from the 'genes' and 'pathway_genes' columns.

expand_genes_to_rows <- function(df, gene_col = "genes") {
  df %>%
    # Ensure gene_col is character (in case it's factor)
    mutate(across(all_of(gene_col), as.character)) %>%
    # Split gene strings into separate rows
    separate_rows({{ gene_col }}, sep = "\\s+") %>%
    # Rename column back to consistent name
    rename(gene_id = {{ gene_col }})
}

expand_genes_to_rows_stringdb <- function(df) {
  # For stringdb datasets: split both protein ID and label columns
  df %>%
    mutate(across(c(matching_proteins_id_network, matching_proteins_labels_network), as.character)) %>%
    separate_rows(matching_proteins_id_network, matching_proteins_labels_network, sep = ",")
}

## Apply function to all dataframes
# Per miRNA
expanded_per_mirna_shinygo <- expand_genes_to_rows(important_per_mirna_shinygo, gene_col = "genes")
expanded_per_mirna_stringdb <- expand_genes_to_rows_stringdb(important_per_mirna_stringdb)

# Venny
expanded_venny_shinygo <- expand_genes_to_rows(important_venny_shinygo, gene_col = "genes")
expanded_venny_stringdb <- expand_genes_to_rows_stringdb(important_venny_stringdb)

# All
expanded_all_shinygo <- expand_genes_to_rows(important_all_shinygo, gene_col = "genes")
expanded_all_stringdb <- expand_genes_to_rows_stringdb(important_all_stringdb)

# ==== FIX AND FUSE MAPPE PROTEIN IDS DFS ====
## Add a species column to each mapped protein ids dataframe
# For ensembl metazoa
aae_mapped_protein_ids_ensembl <- aae_mapped_protein_ids_ensembl |>
  mutate(species = "Aedes aegypti")
aal_mapped_protein_ids_ensembl <- aal_mapped_protein_ids_ensembl |>
  mutate(species = "Aedes albopictus")

# For stringdb
aae_mapped_protein_ids_stringdb <- aae_mapped_protein_ids_stringdb |>
  mutate(species = "Aedes aegypti")
aal_mapped_protein_ids_stringdb <- aal_mapped_protein_ids_stringdb |>
  mutate(species = "Aedes albopictus")

## Combine the mapped protein ids dataframes into one
# For ensembl metazoa
mapped_protein_ids_ensembl <- bind_rows(
  aae_mapped_protein_ids_ensembl,
  aal_mapped_protein_ids_ensembl
)

## For stringdb
mapped_protein_ids_stringdb <- bind_rows(
  aae_mapped_protein_ids_stringdb,
  aal_mapped_protein_ids_stringdb
)

