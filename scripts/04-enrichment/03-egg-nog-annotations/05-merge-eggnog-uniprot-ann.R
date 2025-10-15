# ~~~~~ MERGE EGGNOG AND UNIPROT ANNOTATIONS ~~~~~
# This script will merge uniprot annotation table with eggnog annotation table by `uniprot_id`.
# Only selected rows will be picked for the merge.
# ===== LIBRARIES =====
library(dplyr)
library(tidylog, warn.conflicts = FALSE)

# ===== LOAD FILES =====
# Load eggnog annotation files
source("scripts/04-enrichment/03-egg-nog-annotations/04-eggnog-statistics.R")
eggnog_aae_all_down <- eggnog$aae_all_down
eggnog_aae_all <- eggnog$aae_all
eggnog_aae_per_mirna <- eggnog$aae_per_mirna
eggnog_aae_per_mirna_down <- eggnog$aae_per_mirna_down
eggnog_aal_all <- eggnog$aal_all
eggnog_aal_per_mirna <- eggnog$aal_per_mirna

# Load uniprot annotation files
aae_all_annotated <- read.csv("results/02-enrichment/05-eggnog-annotation/aae_all_annotated.csv")
aae_all_down_annotated <- read.csv("results/02-enrichment/05-eggnog-annotation/aae_all_down_annotated.csv")
aae_per_mirna_annotated <- read.csv("results/02-enrichment/05-eggnog-annotation/aae_per_mirna_annotated.csv")
aae_per_mirna_down_annotated <- read.csv("results/02-enrichment/05-eggnog-annotation/aae_per_mirna_down_annotated.csv")
aal_all_annotated <- read.csv("results/02-enrichment/05-eggnog-annotation/aal_all_annotated.csv")
aal_per_mirna_annotated <- read.csv("results/02-enrichment/05-eggnog-annotation/aal_per_mirna_annotated.csv")
