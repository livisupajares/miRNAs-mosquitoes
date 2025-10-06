# ~~~~~ SEPARATE DF BY SPECIES ~~~~~
# This script prepares the data to be used in BLAST analysis for further annotation by separating these dataframes by species.
#
# ===== Add libraries =====
library(dplyr)
library(tidylog, warn.conflicts = FALSE)

# ===== Import data =====
source("scripts/04-enrichment/03-blast-annotations/01-clean-annotation.R")
