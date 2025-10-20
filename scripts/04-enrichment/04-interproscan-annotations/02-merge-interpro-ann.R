# ~~~~~ MERGE INTERPRO AND THE REST OF THE ANNOTATIONS ~~~~~
# This script will merge interpro annotation table with the merged annotation table from `05-merge-eggnog-uniprot-ann.R` by `uniprot_id`.
# 
# ===== LIBRARIES =====
library(dplyr)
library(tidylog, warn.conflicts = FALSE)

# ===== LOAD FILES =====
# Load interpro annotation files
source("scripts/04-enrichment/04-interproscan-annotations/01-interpro-ann-statistics.R")

# Remove unused data
rm(aae_all_down_interpro)
rm(aae_all_interpro)
rm(aae_per_mirna_interpro)
rm(aae_per_minra_down_interpro)
rm(aal_all_interpro)
rm(aal_per_mirna_interpro)
rm(headers)
rm(interpro)
rm(interpro_headers)
rm(interpro_clean)

# Load merged annotation table from `05-merge-eggnog-uniprot-ann.R`
aae_all_egg_uni <- read.csv("results/02-enrichment/07-tidying-results/01-uniprot-eggnog/aae-all-merged.csv")
aae_all_down_egg_uni <- read.csv("results/02-enrichment/07-tidying-results/01-uniprot-eggnog/aae-all-down-merged.csv")
aae_per_mirna_egg_uni <- read.csv("results/02-enrichment/07-tidying-results/01-uniprot-eggnog/aae-per-mirna-merged.csv")
aae_per_mirna_down_egg_uni <- read.csv("results/02-enrichment/07-tidying-results/01-uniprot-eggnog/aae-per-mirna-down-merged.csv")
aal_all_egg_uni <- read.csv("results/02-enrichment/07-tidying-results/01-uniprot-eggnog/aal-all-merged.csv")
aal_per_mirna_egg_uni <- read.csv("results/02-enrichment/07-tidying-results/01-uniprot-eggnog/aal-per-mirna-merged.csv")

# ==== MERGE DATABASES ====
aae_all_merged <- merge(interpro_important$aae_all, aae_all_egg_uni, by = "uniprot_id", all.y = TRUE)
aae_all_down_merged <- merge(interpro_important$aae_all_down, aae_all_down_egg_uni, by = "uniprot_id", all.y = TRUE)
aae_per_mirna_merged <- merge(interpro_important$aae_per_mirna, aae_per_mirna_egg_uni, by = "uniprot_id", all.y = TRUE)
aae_per_mirna_down_merged <- merge(interpro_important$aae_per_mirna_down, aae_per_mirna_down_egg_uni, by = "uniprot_id", all.y = TRUE)
aal_all_merged <- merge(interpro_important$aal_all, aal_all_egg_uni, by = "uniprot_id", all.y = TRUE)
aal_per_mirna_merged <- merge(interpro_important$aal_per_mirna, aal_per_mirna_egg_uni, by = "uniprot_id", all.y = TRUE)

