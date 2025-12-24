# ~~~~~ FUSE ENRICHMENT RESULTS ~~~~~
# This script is used to fuse the enrichment results so at the end, we will get
# per-mirna stringdb, all stringdb, where each dataframe will have results for both species Aedes aegypti and Aedes albopictus.

# ==== Load libraries ====
library(dplyr)
library(forcats)
library(stringr)

# ==== IMPORT DATABASES TO BE FUSED ====
## Per miRNA
# Per mirna stringdb
aae_per_mirna_stringdb <- read.csv("results/02-enrichment/02-exports-google-sheets/aae-per-mirna-stringdb-export.csv")
aal_per_mirna_stringdb <- read.csv("results/02-enrichment/02-exports-google-sheets/aal-per-mirna-stringdb-export.csv")

## All
# All stringdb
aae_all_stringdb <- read.csv("results/02-enrichment/02-exports-google-sheets/aae-all-stringdb-export.csv")
aal_all_stringdb <- read.csv("results/02-enrichment/02-exports-google-sheets/aal-all-stringdb-export.csv") # Ignore warning

## Down-regulated aae
## These are the datasets of down-regulated aae enrichment whose miRNAs are also found on the up-regulated aal set.
# Per-mirna
aae_per_mirna_down <- read.csv("results/02-enrichment/02-exports-google-sheets/aae-per-mirna-down-stringdb-export.csv")
# All
aae_all_down <- read.csv("results/02-enrichment/02-exports-google-sheets/aae-all-down-stringdb-export.csv")

# ==== FUSE DATA ====
# Fuse data frames by row binding
# Per miRNA
per_mirna_stringdb <- rbind(aae_per_mirna_stringdb, aal_per_mirna_stringdb)

# All
all_stringdb <- rbind(aae_all_stringdb, aal_all_stringdb)

# ==== VERIFY INTEGRITY OF DATA ====
# Convert dataset column to factors
# Per miRNA
per_mirna_stringdb$dataset <- as.factor(per_mirna_stringdb$dataset)

# All
all_stringdb$dataset <- as.factor(all_stringdb$dataset)

# Down-regulated aae
# Per miRNA
aae_per_mirna_down$dataset <- as.factor(aae_per_mirna_down$dataset)

# All
aae_all_down$dataset <- as.factor(aae_all_down$dataset)

# Make sure each dataset column has unique levels with no misspelling/duplication
## Per-mirna STRINGDB
levels_per_mirna_stringdb <- unique(per_mirna_stringdb$dataset)
print(sort(levels_per_mirna_stringdb))

# Merge levels if they are misspelled duplicates using the forcats package
# This is done to ensure that the levels are consistent across datasets.
per_mirna_stringdb <- per_mirna_stringdb |>
  mutate(dataset = fct_collapse(dataset,
    # Merge Reactome levels
    "Reactome" = c("Reactoma", "Reactome"),

    # Merge Local Network Cluster variants
    "Local Network Cluster String" = "Local Network Cluster"
  ))

# Now get the updated levels to verify
levels_per_mirna_stringdb <- unique(per_mirna_stringdb$dataset)
print(sort(levels_per_mirna_stringdb))

## All STRINGDB
levels_all_stringdb <- unique(all_stringdb$dataset)
print(sort(levels_all_stringdb))

# Change level names if they are misspelled duplicates using the forcats package
# This is done to ensure that the levels are consistent across datasets.
all_stringdb <- all_stringdb |>
  mutate(dataset = fct_recode(dataset,
    "Local Network Cluster String" = "Local Network Cluter"
  ))

# Now get the updated levels to verify
levels_all_stringdb <- unique(all_stringdb$dataset)
print(sort(levels_all_stringdb))

# Down-regulated aae
# Per miRNA
levels_per_mirna_down_stringdb <- unique(aae_per_mirna_down$dataset)
print(sort(levels_per_mirna_down_stringdb))

# All
levels_all_down_stringdb <- unique(aae_all_down$dataset)
print(sort(levels_all_down_stringdb))

# ==== SAVE RESULTS TO CSV ====
# Save the fused data frames to .csv files
# Final enriched processes
# Per miRNA
write.csv(per_mirna_stringdb, "results/02-enrichment/03-fused-enrichments-by-species/per-mirna-stringdb.csv", row.names = FALSE)

# All
write.csv(all_stringdb, "results/02-enrichment/03-fused-enrichments-by-species/all-stringdb.csv", row.names = FALSE)

# NOTE: No need to save new dataset for aae down-regulated because we didn't fuse them and also, the dataset levels weren't modificated.
