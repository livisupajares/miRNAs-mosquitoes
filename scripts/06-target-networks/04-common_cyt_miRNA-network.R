# ~~~~ miRNA network cytoscape ~~~~~
# Make input tables for cytoscape

# ==== LIBRARIES ====
library(dplyr)
library(purrr)
library(stringr)
library(tidylog, warn.conflicts = FALSE)

# ==== IMPORT DATA ====
# ==== uniprot enrich common ====
## all
final_ann_all <- read.csv("results/04-heatmap/final_ann_all.csv", na = NA)

## per-mirna
final_ann_per_mirna <- read.csv("results/04-heatmap/final_ann_per_mirna.csv")

# ==== FILTER BY SPECIES AND COMMON MIRNAS ====
# Per-mirna
aae_common_per_mirna <- final_ann_per_mirna %>%
  filter(
    common_mirna == "yes",
    species == "Aedes aegypti"
  )

aal_common_per_mirna <- final_ann_per_mirna %>%
  filter(
    common_mirna == "yes",
    species == "Aedes albopictus"
  )

# ==== TABLE FOR COMMON ====
# ==== matching file ====
# Per-mirna Aedes aegypti
aae_common_per_mirna_matching <- aae_common_per_mirna %>%
  pivot_longer(
    cols = c(mirna, term_description),
    names_to = "source",
    values_to = "mirna/enriched_term"
  ) %>%
  select(uniprot_id, `mirna/enriched_term`) %>%
  filter(!is.na(`mirna/enriched_term`) & `mirna/enriched_term` != "") %>%
  # Clean only enriched terms (those with spaces)
  mutate(`mirna/enriched_term` = if_else(
    str_detect(`mirna/enriched_term`, "\\s"), # has space → enriched term
    str_replace(`mirna/enriched_term`, "^Mixed,\\s*incl\\.?\\s*", "") %>%
      str_remove_all(","), # remove commas
    `mirna/enriched_term` # leave miRNA unchanged
  ))

# Per-mirna Aedes albopictus
aal_common_per_mirna_matching <- aal_common_per_mirna %>%
  pivot_longer(
    cols = c(mirna, term_description),
    names_to = "source",
    values_to = "mirna/enriched_term"
  ) %>%
  select(uniprot_id, `mirna/enriched_term`) %>%
  filter(!is.na(`mirna/enriched_term`) & `mirna/enriched_term` != "") %>%
  # Clean only enriched terms (those with spaces)
  mutate(`mirna/enriched_term` = if_else(
    str_detect(`mirna/enriched_term`, "\\s"), # has space → enriched term
    str_replace(`mirna/enriched_term`, "^Mixed,\\s*incl\\.?\\s*", "") %>%
      str_remove_all(","), # remove commas
    `mirna/enriched_term` # leave miRNA unchanged
  ))

# ==== naming file =====
# Per-mirna Aedes aegypti
aae_common_per_mirna_names <- aae_common_per_mirna_matching %>%
  pivot_longer(
    cols = everything(),
    names_to = "original_col",
    values_to = "name"
  ) %>%
  # Classify based on content of 'name'
  mutate(type = case_when(
    original_col == "uniprot_id" ~ "protein",
    grepl("^[a-z]{3}-mir", name, ignore.case = TRUE) ~ "miRNA",
    grepl(" ", name) ~ "enriched term", # terms usually have spaces
    TRUE ~ "enriched term" # fallback
  )) %>%
  select(name, type) %>%
  distinct(name, type)

# Per-mirna Aedes albopictus
aal_common_per_mirna_names <- aal_common_per_mirna_matching %>%
  pivot_longer(
    cols = everything(),
    names_to = "original_col",
    values_to = "name"
  ) %>%
  # Classify based on content of 'name'
  mutate(type = case_when(
    original_col == "uniprot_id" ~ "protein",
    grepl("^[a-z]{3}-mir", name, ignore.case = TRUE) ~ "miRNA",
    grepl(" ", name) ~ "enriched term", # terms usually have spaces
    TRUE ~ "enriched term" # fallback
  )) %>%
  select(name, type) %>%
  distinct(name, type)

# ==== SAVE TABLES ====
# ==== matching file ====
# Per-mirna Aedes aegypti
write.csv(aae_common_per_mirna_matching, "results/05-network-graph/04-common/aae_per_mirna_matching.csv", row.names = FALSE)

# Per-mirna Aedes albopictus
write.csv(aal_common_per_mirna_matching, "results/05-network-graph/04-common/aal_per_mirna_matching.csv", row.names = FALSE)

# ==== naming file =====
# Per-mirna Aedes aegypti
write.csv(aae_common_per_mirna_names, "results/05-network-graph/04-common/aae_per_mirna_names.csv", row.names = FALSE)

# Per-mirna Aedes albopictus
write.csv(aal_common_per_mirna_names, "results/05-network-graph/04-common/aal_per_mirna_names.csv", row.names = FALSE)
