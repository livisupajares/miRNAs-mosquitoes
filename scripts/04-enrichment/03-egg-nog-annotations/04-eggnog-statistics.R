# ~~~~~ EggNog Statistics ~~~~~~
# This script is to see how many uniprot ids were not annotated with eggnog-mapper
# and how many were annotated with eggnog-mapper.

# ===== LOAD LIBRARIES =====
library(dplyr)
library(stringr)
library(tidylog, warn.conflicts = FALSE)

# ===== LOAD TSV DATA ======
aae_all_eggnog <- read.csv("databases/04-eggnog-annotation/aae_all_annotated.tsv", sep = "\t", stringsAsFactors = FALSE, colClasses = "character")  # force all columns to character
aae_all_down_eggnog <- read.csv("databases/04-eggnog-annotation/aae_all_down_annotated.tsv", sep = "\t", stringsAsFactors = FALSE, colClasses = "character")
aae_per_mirna_eggnog <- read.csv("databases/04-eggnog-annotation/aae_per_mirna_annotated.tsv", sep = "\t", stringsAsFactors = FALSE, colClasses = "character")
aae_per_mirna_down_eggnog <- read.csv("databases/04-eggnog-annotation/aae_per_mirna_down_annotated.tsv", sep = "\t", stringsAsFactors = FALSE, colClasses = "character")
aal_all_eggnog <- read.csv("databases/04-eggnog-annotation/aal_all_annotated.tsv", sep = "\t", stringsAsFactors = FALSE, colClasses = "character")
aal_per_mirna_eggnog <- read.csv("databases/04-eggnog-annotation/aal_per_mirna_annotated.tsv", sep = "\t", stringsAsFactors = FALSE, colClasses = "character")

# ==== TIDY DATA =====
# Store dataframes in a list for easier processing
eggnog <- list(
  "aae_all_down" = aae_all_down_eggnog,
  "aae_all" = aae_all_eggnog,
  "aae_per_mirna" = aae_per_mirna_eggnog,
  "aae_per_mirna_down" = aae_per_mirna_down_eggnog,
  "aal_all" = aal_all_eggnog,
  "aal_per_mirna" = aal_per_mirna_eggnog
)
# Change cells with "-" to NA
eggnog <- lapply(eggnog, function(df){
  df[] <- lapply(df, na_if, "-")
  return(df)
})

View(eggnog$aae_all_down)

# Split `X.query` column to extract only uniprot ids, if uniparc id is detected, do nothing
eggnog <- lapply(eggnog, function(df) {
  # Create an empty column called `uniprot_id` and use regex
  # We use case_when instead of if, and ifelse bc evaluates vectorized conditions (such as a df) with an unlimited amount of outcomes
  df[] <- df %>% mutate(uniprot_id = case_when(
    # If it matches UniProt format (starts with tr| or sp| etc.)
    str_detect(X.query, "^[a-z]{2}\\|[^|]+\\|") ~ str_extract(X.query, "^[a-z]{2}\\|([^|]+)\\|", group = 1),
    # Otherwise, assume it's UniParc or other ID → keep original
    TRUE ~ X.query
  ), .after = "X.query")
})

View(eggnog$aae_all_down)
View(eggnog$aae_all)
View(eggnog$aae_per_mirna_down)
View(eggnog$aae_per_mirna)
View(eggnog$aal_all)
View(eggnog$aal_per_mirna)

# Remove last three rows
eggnog <- lapply(eggnog, function(df){
  df <- df %>% slice(1:(n() - 3))
})
