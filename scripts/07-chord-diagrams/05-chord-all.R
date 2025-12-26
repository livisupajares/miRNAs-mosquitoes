# ~~~~ CHORD DIAGRAMS FOR "ALL" TARGETS ~~~~
# This script

# ===== Libraries =====
library(circlize)
library(dplyr)
library(tidyr)
library(tidylog, warn.conflicts = FALSE)

# ===== Import data =====
source("scripts/07-chord-diagrams/01-filter-subgroups.R")
rm(aae_common_all)
rm(aae_common_per_mirna)
rm(aae_per_mirna)
rm(aal_common_per_mirna)
rm(aal_per_mirna)
rm(common_per_mirna)
rm(per_mirna_new)
