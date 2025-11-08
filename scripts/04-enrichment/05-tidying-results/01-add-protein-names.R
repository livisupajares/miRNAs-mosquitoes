# ~~~~~ ADD PROTEIN NAMES ~~~~~~~
# This script add protein names to both "all" and "per-mirna" datasets with annotation data. It add a new column called `protein_name` that is next to the `uniprot_id` column. Then, using regex, it checks if the `matching_proteins_labels_network` column contains a VectorBase/UniProt-like ID (which we want to avoid using as a name). If it does not match that pattern, it uses that value as the protein name. If it does match, it checks if there is a preferred name from eggNOG and uses that if available. If neither is suitable, it falls back to using the UniProt ID as the protein name.

# ==== Libraries =====
library(dplyr)
library(stringr)
library(tidylog, warn.conflicts = FALSE)

# ==== Import data =====
# Import data from the interpro annotation and fused both species

# ALL
all <- read.csv("results/04-heatmap/final_ann_all.csv", na.strings = c("", NA))

# PER - MIRNA
per_mirna <- read.csv("results/04-heatmap/final_ann_per_mirna.csv", na.strings = c("", NA))

# ==== Add protein names ====
# Define a helper function to check if a string looks like a VectorBase/UniProt ID
is_vectorbase_id <- function(x) {
  # Handle NA/empty first
  empty_or_na <- is.na(x) | x == ""

  # Pattern 1: VectorBase-like with 6+ digits (e.g., AAEL005895)
  long_alphanum_id <- str_detect(x, "^[A-Z]{2,4}\\d{5,}$")

  # Pattern 2: Underscore-separated IDs (e.g., RP20_CCG012365 or J9EAN8_AEDAE)
  underscore_id <- str_detect(x, "^[A-Z0-9]+_[A-Z0-9]+$")

  # Combine: TRUE if it matches unwanted ID patterns
  empty_or_na | long_alphanum_id | underscore_id
}

# For 'all'
all_new <- all %>%
  mutate(
    protein_name = case_when(
      !is_vectorbase_id(matching_proteins_labels_network) ~ matching_proteins_labels_network,
      !is.na(preferred_name_eggnog) & preferred_name_eggnog != "" ~ preferred_name_eggnog,
      TRUE ~ uniprot_id
    ),
    .after = "uniprot_id"
  )

# For 'per_mirna'
per_mirna_new <- per_mirna %>%
  mutate(
    protein_name = case_when(
      !is_vectorbase_id(matching_proteins_labels_network) ~ matching_proteins_labels_network,
      !is.na(preferred_name_eggnog) & preferred_name_eggnog != "" ~ preferred_name_eggnog,
      TRUE ~ uniprot_id
    ),
    .after = "uniprot_id"
  )

# ==== Export data with protein names added =====
write.csv(
  all_new,
  "results/04-heatmap/final_ann_all.csv",
  row.names = FALSE
)

# For 'per_mirna'
write.csv(
  per_mirna_new,
  "results/04-heatmap/final_ann_per_mirna.csv",
  row.names = FALSE
)
