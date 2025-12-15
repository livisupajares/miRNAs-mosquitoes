# ~~~~~~ CONVERT UNIQUE UNIPROT IDS TO TXT FILES ~~~~~~
# This script converts unique `matching_proteins_id_network` into text files and then using the fetch-uniprot-prot-seq.py script to get the sequences for subsequent EggNog mapping.

# ===== Add libraries =====
library(dplyr)
library(tidylog, warn.conflicts = FALSE)

# ===== Import data =====
source("scripts/04-enrichment/03-egg-nog-annotations/02-separate-df-by-species.R")

# ===== Extract Uniprot IDs ====
# Only Unique IDs
writeLines(unique(full_expanded_all_down_stringdb_annotated$matching_proteins_id_network), con = "results/02-enrichment/05-eggnog-annotation/uniprot_ids_txt/aae_all_down_annotated.txt")

writeLines(unique(aae_all_annotated$matching_proteins_id_network), con = "results/02-enrichment/05-eggnog-annotation/uniprot_ids_txt/aae_all_annotated.txt")

writeLines(unique(aal_all_annotated$matching_proteins_id_network), con = "results/02-enrichment/05-eggnog-annotation/uniprot_ids_txt/aal_all_annotated.txt")

writeLines(unique(full_expanded_per_mirna_down_stringdb_annotated$matching_proteins_id_network), con = "results/02-enrichment/05-eggnog-annotation/uniprot_ids_txt/aae_per_mirna_down_annotated.txt")

writeLines(unique(aae_per_mirna_annotated$matching_proteins_id_network), con = "results/02-enrichment/05-eggnog-annotation/uniprot_ids_txt/aae_per_mirna_annotated.txt")

writeLines(unique(aal_per_mirna_annotated$matching_proteins_id_network), con = "results/02-enrichment/05-eggnog-annotation/uniprot_ids_txt/aal_per_mirna_annotated.txt")
