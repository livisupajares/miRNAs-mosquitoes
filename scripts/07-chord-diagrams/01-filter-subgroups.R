# ~~~~ FILTER SUBGROUPS ~~~~~~~
# This script filters the all_new and per_mirna_new to new subgroups for chord diagrams.
# The groups are:
# - Per-mirna common: Aedes albopictus (up-regulated) and Aedes aegypti (down-regulated)
# - All common (Aedes aegypti down-regulated)
# - Per-mirna: Aedes aegypti and Aedes albopictus
# - All: Aedes aegypti and Aedes albopictus

# ===== Libraries =====
library(dplyr)
library(tidylog, warn.conflicts = FALSE)

# ===== Import data =====
# Import 01-add-protein-names.R to get 'all_new' and 'per_mirna_new' data frames
source("scripts/04-enrichment/05-tidying-results/01-add-protein-names.R")
rm(all)
rm(per_mirna)
rm(is_vectorbase_id)

# ===== Filter subgroups =====
# Per-mirna common: Aedes albopictus (up-regulated) and  Aedes aegypti (down-regulted)
common_per_mirna <- per_mirna_new %>%
  filter(
    common_mirna == "yes"
  )

aae_common_per_mirna <- per_mirna_new %>%
  filter(
    common_mirna == "yes",
    species == "Aedes aegypti"
  )

aal_common_per_mirna <- per_mirna_new %>%
  filter(
    common_mirna == "yes",
    species == "Aedes albopictus"
  )

# All common (Aedes aegypti down-regulated)
aae_common_all <- all_new %>%
  filter(
    mirna_expression == "down-regulated"
  )

# Per-mirna: Aedes aegypti and Aedes albopictus
aae_per_mirna <- per_mirna_new %>%
  filter(
    species == "Aedes aegypti"
  )

aal_per_mirna <- per_mirna_new %>%
  filter(
    species == "Aedes albopictus"
  )

# All: Aedes aegypti and Aedes albopictus
aae_all <- all_new %>%
  filter(
    species == "Aedes aegypti"
  )

aal_all <- all_new %>%
  filter(
    species == "Aedes albopictus"
  )
