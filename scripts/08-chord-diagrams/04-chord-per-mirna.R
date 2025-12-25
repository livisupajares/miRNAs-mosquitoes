# ~~~~ CHORD DIAGRAMS FOR "PER-MIRNA" TARGETS ~~~~
# This script

# ===== Libraries =====
library(circlize)
library(dplyr)
library(tidyr)
library(tidylog, warn.conflicts = FALSE)

# ===== Import data =====
source("scripts/07-chord-diagrams/01-filter-subgroups.R")
rm(aae_all)
rm(aae_common_all)
rm(aae_common_per_mirna)
rm(aal_all)
rm(aal_common_per_mirna)
rm(all_new)
rm(common_per_mirna)
