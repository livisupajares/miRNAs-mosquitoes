# ~~~~ miRNA network cytoscape ~~~~~
# Make input tables for cytoscape

# ==== LIBRARIES ====
library(dplyr)
library(purrr)
library(tidylog, warn.conflicts = FALSE)

# ==== IMPORT DATA ====
# ==== uniprot enrich full ====
## all
final_ann_all <- read.csv("results/04-heatmap/final_ann_all.csv", na = NA)

## per-mirna
final_ann_per_mirna <- read.csv("results/04-heatmap/final_ann_per_mirna.csv")

# ==== TABLE FROM ENRICHMENTS ====
# ==== matching file ====
# Per-miRNA
# split dataframe into Aedes aegypti and Aedes albopictus
aae_ann_per_mirna <- final_ann_per_mirna %>%
  filter(species == "Aedes aegypti")

aal_ann_per_mirna <- final_ann_per_mirna %>%
  filter(species == "Aedes albopictus")

# Add results from above into a list
enrich_matching_cyt <- list(
  "aae_enrich_cyt" = aae_ann_per_mirna,
  "aal_enrich_cyt" = aal_ann_per_mirna
)

# Create matching file table
enrich_matching_cyt <- enrich_matching_cyt %>%
  map(~ .x %>%
    pivot_longer(
      cols = c(mirna, term_description),
      names_to = "source",
      values_to = "mirna/enriched_term"
    ) %>%
    select(uniprot_id, `mirna/enriched_term`) %>%
    filter(!is.na(`mirna/enriched_term`) & `mirna/enriched_term` != ""))

# All
# split dataframe into Aedes aegypti and Aedes albopictus
aae_ann_all <- final_ann_all %>%
  filter(species == "Aedes aegypti")

aal_ann_all <- final_ann_all %>%
  filter(species == "Aedes albopictus")

# Add results from above into a list
enrich_all_cyt <- list(
  "aae_enrich_cyt" = aae_ann_all,
  "aal_enrich_cyt" = aal_ann_all
)

# Create.matching file table
enrich_all_cyt <- enrich_all_cyt %>%
  map(~ .x %>%
    pivot_longer(
      cols = c(term_description),
      names_to = "source",
      values_to = "enriched_term"
    ) %>%
    select(uniprot_id, enriched_term) %>%
    filter(!is.na(enriched_term) & enriched_term != ""))

# ==== name file ====
# Per-miRNA
# Add results from above into a list
enrich_names_cyt <- list(
  "aae_enrich_cyt" = enrich_matching_cyt$aae_enrich_cyt,
  "aal_enrich_cyt" = targets_matching_cyt$aae_up_targets_cyt
)

# Create name file table
enrich_names_cyt <- enrich_names_cyt %>%
  map(~ .x %>%
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
    distinct(name, type))

# All
# Add results from above into a list
enrich_names_all_cyt <- list(
  "aae_enrich_cyt" = enrich_all_cyt$aae_enrich_cyt,
  "aal_enrich_cyt" = enrich_all_cyt$aal_enrich_cyt
)

# Create name file table
enrich_names_all_cyt <- enrich_names_all_cyt %>%
  map(~ .x %>%
    pivot_longer(
      cols = everything(),
      names_to = "original_col",
      values_to = "name"
    ) %>%
    # Classify based on content of 'name'
    mutate(type = case_when(
      original_col == "uniprot_id" ~ "protein",
      grepl(" ", name) ~ "enriched term", # terms usually have spaces
      TRUE ~ "enriched term" # fallback
    )) %>%
    select(name, type) %>%
    distinct(name, type))

# ==== SAVE RESULTS ====
## Enrichment
## Matching file
## Name file
