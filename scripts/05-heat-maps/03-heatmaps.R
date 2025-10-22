# ~~~~  HEATMAPS ~~~~~
# This script will add one extra variable to all imported datasets to indicate if it comes from up or down-regulated miRNAs.
# Then, it will add another extra variable to indicate which miRNAs are in the common data set (miR-276-5p, miR-2945-3p) 
# combines all "per_mirna" datasets into one dataframe, and all "all" datasets into another dataframe.
# Then it will create two heatmaps using tidyheatmaps
# This process will be repeated (probably) for the full_annotated dataset when the BLAST analysis is done.
 
# ===== Add libraries =====
library(tidyverse)
library(tidyheatmaps)
library(tidylog, warn.conflicts = FALSE)

# ===== Import data =====
# aae and aal up-regulated
# Per-mirna
important_per_mirna_stringdb <- read.csv(
  "results/02-enrichment/03-enrichments-important-process/per-mirna-stringdb.csv"
)

# all
important_all_stringdb <- read.csv(
  "results/02-enrichment/03-enrichments-important-process/all-stringdb.csv"
)

# Aae down-regulated
# Per miRNA
aae_per_mirna_down <- read.csv(
  "results/02-enrichment/02-exports-google-sheets/aae-per-mirna-down-stringdb-export.csv"
)

# All
aae_all_down <- read.csv(
  "results/02-enrichment/02-exports-google-sheets/aae-all-down-stringdb-export.csv"
)
