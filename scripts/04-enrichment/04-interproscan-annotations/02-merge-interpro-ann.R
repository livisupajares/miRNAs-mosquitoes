# ~~~~~ MERGE INTERPRO AND THE REST OF THE ANNOTATIONS ~~~~~
# This script will merge interpro annotation table with the merged annotation table from `05-merge-eggnog-uniprot-ann.R` by `uniprot_id`.
# 
# ===== LIBRARIES =====
library(dplyr)
library(tidylog, warn.conflicts = FALSE)

