# ~~~~~~ SCRIPT FOR PARSING UNMAPPED PROTEIN IDs ~~~~~~
# This script gets a list of the unmapped protein IDs from the annotated PPI data

# ===== IMPORT LIBRARIES ======
library("dplyr")
# The goal of tidylog is to provide feedback about dplyr and tidyr operations. It provides simple wrapper functions for almost all dplyr and tidyr functions, such as filter, mutate, select, full_join, and group_by.
# url: https://github.com/elbersb/tidylog
library("tidylog", warn.conflicts = FALSE)

# ===== IMPORT DATA ======
# Import the annotated PPI data
aae_ppi_annotated <- read.csv("results/03-ppi/aae_string_protein_annotations_with_kegg.tsv", sep = "\t", na.strings = c("", "NA"))
aal_ppi_annotated <- read.csv("results/03-ppi/aal_string_protein_annotations_with_kegg.tsv", sep = "\t", na.strings = c("", "NA"))

# ===== EXTRACT UNMAPPED IDs ======
# Extract unmapped IDs from the annotated PPI data
# Get mapped_ids from rows where kegg_is is NA
aae_unmapped_ids <- aae_ppi_annotated %>%
  filter(is.na(kegg_id)) %>%
  select(mapped_id)

aal_unmapped_ids <- aal_ppi_annotated %>%
  filter(is.na(kegg_id)) %>%
  select(mapped_id)

# Filter only rows with kegg_ids that are not NA
aae_mapped_ids <- aae_ppi_annotated %>%
  filter(!is.na(kegg_id)) %>%
  select(mapped_id)

aal_mapped_ids <- aal_ppi_annotated %>%
  filter(!is.na(kegg_id)) %>%
  select(mapped_id)

# Print unmapped_ids to console without row ids
print(aae_unmapped_ids, row.names = FALSE)
print(aal_unmapped_ids, row.names = FALSE)
