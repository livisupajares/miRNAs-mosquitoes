# ~~~~ miRNA network cytoscape ~~~~~
# Make input tables for cytoscape

# ==== LIBRARIES ====
library(dplyr)
library(purrr)
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

# ==== TABLE FOR TARGETS ONLY ====
# ==== matching file ====
aae_down_targets <- aae_down_targets %>%
  # Add the "aae-" prefix only to aae_down_targets
  mutate(microRNA = paste0("aae-", microRNA)) %>%
  # Swap microRNA column with mRNA column
  select(mRNA, gene_id, uniprot_id, microRNA, everything())

# Add the 3 dataframe into a list
targets_matching_cyt <- list(
  "aae_down_targets_cyt" = aae_down_targets,
  "aae_up_targets_cyt" = aae_up_targets,
  "aal_up_targets_cyt" = aal_up_targets
)

# Keep only microRNA and uniprot_id column
targets_matching_cyt <- targets_matching_cyt %>%
  map(~ select(.x, uniprot_id, microRNA))

# ==== name file ====
# Add results from above into a list
targets_names_cyt <- list(
  "aae_down_targets_cyt" = targets_matching_cyt$aae_down_targets_cyt,
  "aae_up_targets_cyt" = targets_matching_cyt$aae_up_targets_cyt,
  "aal_up_targets_cyt" = targets_matching_cyt$aal_up_targets_cyt
)

# Create name file table
targets_names_cyt <- targets_names_cyt %>%
  map(~ .x %>%
        pivot_longer(
          cols = everything(),
          names_to = "type",
          values_to = "name"
        ) %>%
        # Map column names to desired type labels
        mutate(type = recode(type,
                             uniprot_id = "protein",
                             microRNA   = "miRNA")) %>%
        distinct(name, type) %>%
        select(name, type)
  )

# ==== TABLE FROM ENRICHMENTS ====
# ==== matching file ====
# ==== name file ====

# ==== SAVE RESULTS ====
# Targets only
## matching file
write.csv(targets_matching_cyt$aae_down_targets_cyt,"results/05-network-graph/targets-only/aae_down_targets_matching.csv", row.names = FALSE)
write.csv(targets_matching_cyt$aae_up_targets_cyt, "results/05-network-graph/targets-only/aae_up_targets_matching.csv", row.names = FALSE)
write.csv(targets_matching_cyt$aal_up_targets_cyt, "results/05-network-graph/targets-only/aal_up_targets_matching.csv", row.names = FALSE)

## name file
write.csv(targets_names_cyt$aae_down_targets_cyt, "results/05-network-graph/targets-only/aae_down_targets_names.csv", row.names = FALSE)
write.csv(targets_names_cyt$aae_up_targets_cyt, "results/05-network-graph/targets-only/aae_up_targets_names.csv", row.names = FALSE)
write.csv(targets_names_cyt$aal_up_targets_cyt, "results/05-network-graph/targets-only/aal_up_targets_names.csv", row.names = FALSE)
