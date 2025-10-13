# ~~~~~ EggNog Statistics ~~~~~~
# This script is to see how many uniprot ids were not annotated with eggnog-mapper
# and how many were annotated with eggnog-mapper.

# ===== LOAD LIBRARIES =====
library(dplyr)
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
