# ~~~~~ EggNog Statistics ~~~~~~
# This script is to see how many uniprot ids were not annotated with eggnog-mapper
# and how many were annotated with eggnog-mapper.

# ===== LOAD LIBRARIES =====
library(dplyr)
library(tidylog, warn.conflicts = FALSE)

# ===== LOAD TSV DATA ======
aae_all_eggnog <- read.csv("databases/04-eggnog-annotation/aae_all_annotated.tsv", sep = "\t")
aae_all_down_eggnog <- read.csv("databases/04-eggnog-annotation/aae_all_down_annotated.tsv", sep = "\t")
aae_per_mirna_eggnog <- read.csv("databases/04-eggnog-annotation/aae_per_mirna_annotated.tsv", sep = "\t")
aae_per_mirna_down_eggnog <- read.csv("databases/04-eggnog-annotation/aae_per_mirna_down_annotated.tsv", sep = "\t")
aal_all_eggnog <- read.csv("databases/04-eggnog-annotation/aal_all_annotated.tsv", sep = "\t")
aal_per_mirna_eggnog <- read.csv("databases/04-eggnog-annotation/aal_per_mirna_annotated.tsv", sep = "\t")
