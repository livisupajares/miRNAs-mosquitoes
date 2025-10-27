# ~~~~ miRNA network cytoscape ~~~~~
# Make input tables for cytoscape

# ==== LIBRARIES ====
library(dplyr)
library(tidylog, warn.conflicts = FALSE)

# ==== IMPORT DATA ====
# ===== miRNA targets ====
## aae down
aae_down_targets <- read.csv("results/01-target-prediction/00-miRNAconsTarget/aae_down/miranda-aae-uniprot-filtered.csv", na = "NA")

## aae up
aae_up_targets <- read.csv("results/01-target-prediction/00-miRNAconsTarget/aae_up/miranda-aae/miranda-aae-uniprot-filtered.csv", na = NA)

## aal up
aal_up_targets <- read.csv("results/01-target-prediction/00-miRNAconsTarget/aal_up/miranda-aal/miranda-aal-uniprot-filtered.csv", na = NA)

# ==== uniprot enrich full ====
## all
final_ann_all <- read.csv("results/04-heatmap/final_ann_all.csv", na = NA)

## per-mirna
final_ann_per_mirna <- read.csv("results/04-heatmap/final_ann_per_mirna.csv")

# ==== uniprot enrich immune ====
## all
all_ann_immune <- read.csv("results/04-heatmap/immune-related-annotations/all_ann_immune.csv")

## per-mirna
per_mirna_ann_immune <- read.csv("results/04-heatmap/immune-related-annotations/per_mirna_ann_immune.csv")
