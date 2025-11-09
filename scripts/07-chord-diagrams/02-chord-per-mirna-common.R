# ~~~~ CHORD DIAGRAMS FOR PER-MIRNA COMMON TARGETS ~~~~
# This script

# ===== Libraries =====
library(circlize)
library(dplyr)
library(tidyr)
library(tidylog, warn.conflicts = FALSE)

# ===== Import data =====
source("scripts/07-chord-diagrams/01-filter-subgroups.R")
rm(all_new)
rm(per_mirna_new)
rm(aae_all)
rm(aae_per_mirna)
rm(aal_per_mirna)
rm(aae_common_all)
rm(aal_all)

