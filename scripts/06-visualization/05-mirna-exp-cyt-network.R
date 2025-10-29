# ~~~~ miRNA network cytoscape ~~~~~
# Make input tables for cytoscape

# ==== LIBRARIES ====
library(dplyr)
library(purrr)
library(stringr)
library(tidylog, warn.conflicts = FALSE)

# ==== IMPORT DATA ====
# ==== uniprot enrich expression ====
## all
final_ann_all <- read.csv("results/04-heatmap/final_ann_all.csv", na = NA)

## per-mirna
final_ann_per_mirna <- read.csv("results/04-heatmap/final_ann_per_mirna.csv")

# ==== FILTER BY MIRNA EXPRESSION & SPECIES ====
# all
# up-regulated
aae_all_up <- final_ann_all %>%
  filter(
    mirna_expression == "up-regulated",
    species == "Aedes aegypti"
  )

aal_all_up <- final_ann_all %>%
  filter(
    mirna_expression == "up-regulated",
    species == "Aedes albopictus"
  )

# down-regulated
aae_all_down <- final_ann_all %>%
  filter(
    mirna_expression == "down-regulated",
    species == "Aedes aegypti"
  )

aal_all_down <- final_ann_all %>%
  filter(
    mirna_expression == "down-regulated",
    species == "Aedes albopictus"
  )

# Per-mirna
# up-regulated
aae_per_mirna_up <- final_ann_per_mirna %>%
  filter(
    mirna_expression == "up-regulated",
    species == "Aedes aegypti"
  )

aal_per_mirna_up <- final_ann_per_mirna %>%
  filter(
    mirna_expression == "up-regulated",
    species == "Aedes albopictus"
  )

# down-regulated
aae_per_mirna_down <- final_ann_per_mirna %>%
  filter(
    mirna_expression == "down-regulated",
    species == "Aedes aegypti"
  )

# There is no down-regulated miRNAs in Aedes albopictus

# ==== TABLE FOR MIRNA EXPRESSION ====
# ==== matching file ====
# ---- All up-regulated ----
## Aedes aegypti
aae_all_up_matching <- aae_all_up %>%
  pivot_longer(
    cols = c(term_description),
    names_to = "source",
    values_to = "enriched_term"
  ) %>%
  select(uniprot_id, enriched_term) %>%
  filter(!is.na(enriched_term) & enriched_term != "")

## Aedes albopictus
aal_all_up_matching <- aal_all_up %>%
  pivot_longer(
    cols = term_description,
    names_to = "source",
    values_to = "enriched_term"
  ) %>%
  select(uniprot_id, `enriched_term`) %>%
  filter(!is.na(`enriched_term`) & `enriched_term` != "") %>%
  # Clean only enriched terms (those with spaces)
  mutate(`enriched_term` = if_else(
    str_detect(`enriched_term`, "\\s"),  # has space → enriched term
    str_replace(`enriched_term`, "^Mixed,\\s*incl\\.?\\s*", "") %>% 
      str_remove_all(","),  # remove commas
    `enriched_term`  # leave miRNA unchanged
  ))

# ----- All down-regulated ----
## Aedes aegyaae_per_mirna_downpti
aae_all_down_matching <- aae_all_down %>%
  pivot_longer(
    cols = term_description,
    names_to = "source",
    values_to = "enriched_term"
  ) %>%
  select(uniprot_id, `enriched_term`) %>%
  filter(!is.na(`enriched_term`) & `enriched_term` != "") %>%
  # Clean only enriched terms (those with spaces)
  mutate(`enriched_term` = if_else(
    str_detect(`enriched_term`, "\\s"),  # has space → enriched term
    str_replace(`enriched_term`, "^Mixed,\\s*incl\\.?\\s*", "") %>% 
      str_remove_all(","),  # remove commas
    `enriched_term`  # leave miRNA unchanged
  ))

## Aedes albopictus
## There are no miRNAs down-regulated in Aedes albopictus

# ----- Per-miRNA up-regulated -----
## Aedes aegypti
aae_per_mirna_up_matching <- aae_per_mirna_up %>%
  pivot_longer(
    cols = c(mirna, term_description),
    names_to = "source",
    values_to = "mirna/enriched_term"
  ) %>%
  select(uniprot_id, `mirna/enriched_term`) %>%
  filter(!is.na(`mirna/enriched_term`) & `mirna/enriched_term` != "") %>%
  # Clean only enriched terms (those with spaces)
  mutate(`mirna/enriched_term` = if_else(
    str_detect(`mirna/enriched_term`, "\\s"),  # has space → enriched term
    str_replace(`mirna/enriched_term`, "^Mixed,\\s*incl\\.?\\s*", "") %>% 
      str_remove_all(","),  # remove commas
    `mirna/enriched_term`  # leave miRNA unchanged
  ))

## Aedes albopictus
aal_per_mirna_up_matching <- aal_per_mirna_up %>%
  pivot_longer(
    cols = c(mirna, term_description),
    names_to = "source",
    values_to = "mirna/enriched_term"
  ) %>%
  select(uniprot_id, `mirna/enriched_term`) %>%
  filter(!is.na(`mirna/enriched_term`) & `mirna/enriched_term` != "") %>%
  # Clean only enriched terms (those with spaces)
  mutate(`mirna/enriched_term` = if_else(
    str_detect(`mirna/enriched_term`, "\\s"),  # has space → enriched term
    str_replace(`mirna/enriched_term`, "^Mixed,\\s*incl\\.?\\s*", "") %>% 
      str_remove_all("[(),]") %>%   # remove commas, parentheses
      str_squish(),                # clean up extra spaces
    `mirna/enriched_term`          # leave miRNA unchanged
  ))

# ----- Per-miRNA down-regulated -----
## Aedes aegypti
aae_per_mirna_down_matching <- aae_per_mirna_down %>%
  pivot_longer(
    cols = c(mirna, term_description),
    names_to = "source",
    values_to = "mirna/enriched_term"
  ) %>%
  select(uniprot_id, `mirna/enriched_term`) %>%
  filter(!is.na(`mirna/enriched_term`) & `mirna/enriched_term` != "") %>%
  # Clean only enriched terms (those with spaces)
  mutate(`mirna/enriched_term` = if_else(
    str_detect(`mirna/enriched_term`, "\\s"),  # has space → enriched term
    str_replace(`mirna/enriched_term`, "^Mixed,\\s*incl\\.?\\s*", "") %>% 
      str_remove_all(","),  # remove commas
    `mirna/enriched_term`  # leave miRNA unchanged
  ))

## Aedes albopictus
# There is no down-regulated miRNAs in Aedes albopictus

# ==== naming file =====
# ---- All up-regulated ----
## Aedes aegypti
aae_all_up_names <- aae_all_up_matching %>%
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
  distinct(name, type)

## Aedes albopictus
aal_all_up_names <- aal_all_up_matching %>%
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
  distinct(name, type)

# ----- All down-regulated ----
## Aedes aegypti
aae_all_down_names <- aae_all_down_matching %>%
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
  distinct(name, type)

## Aedes albopictus
# There is no down-regulated miRNAs in Aedes albopictus

# ----- Per-miRNA up-regulated -----
## Aedes aegypti
aae_per_mirna_up_names <- aae_per_mirna_up_matching %>%
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

## Aedes albopictus
aal_per_mirna_up_names <-
  aal_per_mirna_up_matching %>%
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

# ----- Per-miRNA down-regulated -----
## Aedes aegypti
aae_per_mirna_down_names <- aae_per_mirna_down_matching %>%
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

## Aedes albopictus
# There is no down-regulated miRNA in Aedes albopictus 

# ==== SAVE TABLES ====
# ==== matching file ====
# ---- All up-regulated ----
## Aedes aegypti
write.csv(aae_all_up_matching, "results/05-network-graph/05-expression/aae_all_up_matching.csv", row.names = FALSE)

## Aedes albopictus
write.csv(aal_all_up_matching, "results/05-network-graph/05-expression/aal_all_up_matching.csv", row.names = FALSE)

# ----- All down-regulated ----
## Aedes aegypti
write.csv(aae_all_down_matching, "results/05-network-graph/05-expression/aae_all_down_matching.csv", row.names = FALSE)

## Aedes albopictus
## There is no down-regulated miRNAs in Aedes albopictus

# ----- Per-miRNA up-regulated -----
## Aedes aegypti
write.csv(aae_per_mirna_up_matching, "results/05-network-graph/05-expression/aae_per_mirna_up_matching.csv", row.names = FALSE)

## Aedes albopictus
write.csv(aal_per_mirna_up_matching, "results/05-network-graph/05-expression/aal_per_mirna_up_matching.csv", row.names = FALSE)

# ----- Per-miRNA down-regulated -----
## Aedes aegypti
write.csv(aae_per_mirna_down_matching, "results/05-network-graph/05-expression/aae_per_mirna_down_matching.csv", row.names = FALSE)

## Aedes albopictus
## There is no down-regulated miRNAs in Aedes albopictus

# ==== naming file =====
# ---- All up-regulated ----
## Aedes aegypti
write.csv(aae_all_up_names, "results/05-network-graph/05-expression/aae_all_up_names.csv", row.names = FALSE)

## Aedes albopictus
write.csv(aal_all_up_names, "results/05-network-graph/05-expression/aal_all_up_names.csv", row.names = FALSE)

# ----- All down-regulated ----
## Aedes aegypti
write.csv(aae_all_down_names, "results/05-network-graph/05-expression/aae_all_down_names.csv", row.names = FALSE)

## Aedes albopictus
## There is no down-regulated miRNAs in Aedes albopictus

# ----- Per-miRNA up-regulated -----
## Aedes aegypti
write.csv(aae_per_mirna_up_names, "results/05-network-graph/05-expression/aae_per_mirna_up_names.csv", row.names = FALSE)

## Aedes albopictus
write.csv(aal_per_mirna_up_names, "results/05-network-graph/05-expression/aal_per_mirna_up_names.csv", row.names = FALSE)

# ----- Per-miRNA down-regulated -----
## Aedes aegypti
write.csv(aae_per_mirna_down_names, "results/05-network-graph/05-expression/aae_per_mirna_down_names.csv", row.names = FALSE)

## Aedes albopictus
## There is no down-regulated miRNAs in Aedes albopictus
