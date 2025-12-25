# ~~~~ miRNA network cytoscape ~~~~~
# Make input tables for cytoscape. Taken from this medium article: https://medium.com/@snippetsbio/how-to-use-cytoscape-for-making-interaction-networks-6-simple-steps-176a1e147020

# ==== LIBRARIES ====
library(dplyr)
library(purrr)
library(stringr)
library(tidylog, warn.conflicts = FALSE)

# ==== IMPORT DATA ====
# ==== uniprot enrich immune ====
## all
final_ann_all <- read.csv("results/02-enrichment/07-tidying-results/03-final-enrichment/prot_final_exp_ann_all.csv", na = NA)

## per-mirna
final_ann_per_mirna <- read.csv("results/02-enrichment/07-tidying-results/03-final-enrichment/prot_final_exp_ann_per_mirna.csv")

# ==== FILTER IMMUNE RESULTS ======
immune_all <- final_ann_all %>%
  dplyr::filter(category_of_interest == "immune")

immune_per_mirna <- final_ann_per_mirna %>%
  dplyr::filter(category_of_interest == "immune")

# ===== FILTER COMMON MIRNAS & IMMUNE =====
# There is a immune enrichment on the common (down-regulated) miRNAs (ALL) only for Aedes aegypti
common_immune_all <- final_ann_all %>%
  dplyr::filter(
    category_of_interest == "immune",
    mirna_expression == "down-regulated"
  )

# ==== TABLE FOR COMMON IMMUNE =====
# ==== matching file =====
# There is only Aedes aegypti in the common immune all dataframe
aae_immune_common_matching <- common_immune_all %>%
  pivot_longer(
    cols = c(term_description),
    names_to = "source",
    values_to = "enriched_term"
  ) %>%
  # If only uniprot_id are needed, change protein_name to uniprot_id
  dplyr::select(protein_name, enriched_term) %>%
  dplyr::filter(!is.na(enriched_term) & enriched_term != "") %>%
  # Clean only enriched terms (those with spaces)
  mutate(
    `enriched_term` = if_else(
      str_detect(`enriched_term`, "\\s"), # has space → enriched term
      str_replace(`enriched_term`, "^Mixed,\\s*incl\\.?\\s*", "") %>%
        str_remove_all("[(),]") %>% # remove commas, parentheses
        str_squish(), # clean up extra spaces
      `enriched_term`
    ) # leave miRNA unchanged
  ) %>%
  distinct()

# ===== name file =====
aae_immune_common_name <- aae_immune_common_matching %>%
  pivot_longer(
    cols = everything(),
    names_to = "original_col",
    values_to = "name"
  ) %>%
  # Classify based on content of 'name'
  mutate(type = case_when(
    # If only uniprot_id are needed, change protein_name to uniprot_id
    original_col == "protein_name" ~ "protein",
    grepl(" ", name) ~ "enriched term", # terms usually have spaces
    TRUE ~ "enriched term" # fallback
  )) %>%
  dplyr::select(name, type) %>%
  distinct(name, type)

# ==== TABLE FOR IMMUNE ====
# ===== matching file =====
# Per-miRNA
# There is no Aedes aegypti in the immune per-mirna dataframe
# Only in Aedes albopictus
immune_matching_cyt <- immune_per_mirna %>%
  pivot_longer(
    cols = c(mirna, term_description),
    names_to = "source",
    values_to = "mirna/enriched_term"
  ) %>%
  # If only uniprot_id are needed, change protein_name to uniprot_id
  dplyr::select(protein_name, `mirna/enriched_term`) %>%
  dplyr::filter(!is.na(`mirna/enriched_term`) & `mirna/enriched_term` != "") %>%
  # Clean only enriched terms (those with spaces)
  mutate(`mirna/enriched_term` = if_else(
    str_detect(`mirna/enriched_term`, "\\s"), # has space → enriched term
    str_replace(`mirna/enriched_term`, "^Mixed,\\s*incl\\.?\\s*", "") %>%
      str_remove_all("[(),]") %>% # remove commas, parentheses
      str_squish(), # clean up extra spaces
    `mirna/enriched_term` # leave miRNA unchanged
  ))

# All
# Filter by species and choose not the down-regulated miRNAs
aae_immune_all <- immune_all %>%
  dplyr::filter(species == "Aedes aegypti") %>%
  dplyr::filter(mirna_expression != "down-regulated")
aal_immune_all <- immune_all %>%
  dplyr::filter(species == "Aedes albopictus")

# Add to a list
immune_all_cyt <- list(
  "aae_immune_all_cyt" = aae_immune_all,
  "aal_immune_all_cyt" = aal_immune_all
)

# Create matching file table
immune_all_matching_cyt <- immune_all_cyt %>%
  map(~ .x %>%
    pivot_longer(
      cols = c(term_description),
      names_to = "source",
      values_to = "enriched_term"
    ) %>%
    # If only uniprot_id are needed, change protein_name to uniprot_id
    dplyr::select(protein_name, enriched_term) %>%
    dplyr::filter(!is.na(enriched_term) & enriched_term != "") %>%
    # Clean only enriched terms (those with spaces)
    mutate(
      `enriched_term` = if_else(
        str_detect(`enriched_term`, "\\s"), # has space → enriched term
        str_replace(`enriched_term`, "^Mixed,\\s*incl\\.?\\s*", "") %>%
          str_remove_all("[(),]") %>% # remove commas, parentheses
          str_squish(), # clean up extra spaces
        `enriched_term`
      ) # leave miRNA unchanged
    ) %>%
    distinct())
# ===== name file =====
# Per-miRNA
# There is no Aedes aegypti in the immune per-mirna dataframe
immune_name_cyt <- immune_matching_cyt %>%
  pivot_longer(
    cols = everything(),
    names_to = "original_col",
    values_to = "name"
  ) %>%
  # Classify based on content of 'name'
  mutate(type = case_when(
    # If only uniprot_id are needed, change protein_name to uniprot_id
    original_col == "protein_name" ~ "protein",
    grepl("^[a-z]{3}-mir", name, ignore.case = TRUE) ~ "miRNA",
    grepl(" ", name) ~ "enriched term", # terms usually have spaces
    TRUE ~ "enriched term" # fallback
  )) %>%
  dplyr::select(name, type) %>%
  distinct(name, type)

# All
immune_all_name_cyt <- immune_all_matching_cyt %>%
  map(~ .x %>%
    pivot_longer(
      cols = everything(),
      names_to = "original_col",
      values_to = "name"
    ) %>%
    # Classify based on content of 'name'
    mutate(type = case_when(
      # If only uniprot_id are needed, change protein_name to uniprot_id
      original_col == "protein_name" ~ "protein",
      grepl(" ", name) ~ "enriched term", # terms usually have spaces
      TRUE ~ "enriched term" # fallback
    )) %>%
    dplyr::select(name, type) %>%
    distinct(name, type))

# ==== SAVE FILES ====
## matching files
# per-mirna
write.csv(immune_matching_cyt, "results/03-target-networks/03-immune/aal_per_mirna_immune_matching.csv", row.names = FALSE)

# All
write.csv(immune_all_matching_cyt$aae_immune_all_cyt, "results/03-target-networks/03-immune/aae_all_immune_matching.csv", row.names = FALSE)
write.csv(immune_all_matching_cyt$aal_immune_all_cyt, "results/03-target-networks/03-immune/aal_all_immune_matching.csv", row.names = FALSE)

# All common
write.csv(aae_immune_common_matching, "results/03-target-networks/03-immune/aae_all_common_immune_matching.csv", row.names = FALSE)

## name file
# per-mirna
write.csv(immune_name_cyt, "results/03-target-networks/03-immune/aal_per_mirna_immune_names.csv", row.names = FALSE)

# All
write.csv(immune_all_name_cyt$aae_immune_all_cyt, "results/03-target-networks/03-immune/aae_all_immune_names.csv", row.names = FALSE)
write.csv(immune_all_name_cyt$aal_immune_all_cyt, "results/03-target-networks/03-immune/aal_all_immune_names.csv", row.names = FALSE)

# All common
write.csv(aae_immune_common_name, "results/03-target-networks/03-immune/aae_all_common_immune_names.csv", row.names = FALSE)
