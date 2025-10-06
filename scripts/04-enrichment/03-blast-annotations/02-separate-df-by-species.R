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
