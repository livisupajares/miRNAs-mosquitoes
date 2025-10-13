# ~~~~~ MERGE EGGNOG AND UNIPROT ANNOTATIONS ~~~~~
# This script will merge uniprot annotation table with eggnog annotation table by `uniprot_id`.
# Only selected rows will be picked for the merge.
# ===== LIBRARIES =====
library(dplyr)
library(tidylog, warn.conflicts = FALSE)

# ===== LOAD FILES =====
source("scripts/04-enrichment/03-egg-nog-annotations/04-eggnog-statistics.R")
