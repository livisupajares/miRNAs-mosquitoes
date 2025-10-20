# ~~~~~ MERGING ALL PER MIRNA ~~~~~
# This script is to see:
# - if some uniprot_id doesn't have any annotation or only one annotation
# - Add two variables `mirna_expression` and `common_mirna` to all per-mirna datasets
# - Merge all per-mirna datasets, including the ones with "down", including both species
# - Merge all "all" datasets, including both species.
# - Mantain sorting by `term_description` and by `false_discovery_rate`

# ===== LIBRARIES =====
library(dplyr)
library(tidylog, warn.conflicts = FALSE)

# ===== LOAD FILES =====
# Add merged results
source("scripts/04-enrichment/04-interproscan-annotations/02-merge-interpro-ann.R")

# Remove unused dfs
rm(aae_all_down_egg_uni)
rm(aae_all_down_merged)
rm(aae_all_egg_uni)
rm(aae_all_merged)
rm(aae_per_mirna_down_egg_uni)
rm(aae_per_mirna_down_merged)
rm(aae_per_mirna_egg_uni)
rm(aae_per_mirna_merged)
rm(aal_all_egg_uni)
rm(aal_all_merged)
rm(aal_per_mirna_egg_uni)
rm(aal_per_mirna_merged)
rm(interpro_important)
rm(merged)

