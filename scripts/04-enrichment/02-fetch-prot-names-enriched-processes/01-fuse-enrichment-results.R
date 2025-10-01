# ~~~~~ FUSE ENRICHMENT RESULTS ~~~~~
# This script is used to fuse the enrichment results so at the end, we will get
# per-mirna stringdb, venny stringdb, all stringdb, where each dataframe will have results for both species Aedes aegypti and Aedes albopictus.
# The it will filter it by category of interest
# ==== Load libraries ====
library(dplyr)
library(forcats)
library(stringr)

# ==== IMPORT DATABASES TO BE FUSED ====
## Per miRNA
# Per mirna stringdb
aae_per_mirna_stringdb <- read.csv("results/02-enrichment/02-exports-google-sheets/aae-per-mirna-stringdb-export.csv")
aal_per_mirna_stringdb <- read.csv("results/02-enrichment/02-exports-google-sheets/aal-per-mirna-stringdb-export.csv")

## Venny
# Venny stringdb
aae_venny_stringdb <- read.csv("results/02-enrichment/02-exports-google-sheets/aae-venny-stringdb-export.csv") # No significant enriched processes were found. No data. Ignore warning
aal_venny_stringdb <- read.csv("results/02-enrichment/02-exports-google-sheets/aal-venny-stringdb-export.csv") # No significant enriched processes were found. No data. Ignore warning

## All
# All stringdb
aae_all_stringdb <- read.csv("results/02-enrichment/02-exports-google-sheets/aae-all-stringdb-export.csv")
aal_all_stringdb <- read.csv("results/02-enrichment/02-exports-google-sheets/aal-all-stringdb-export.csv") # No significant enriched processes were found. No data. Ignore warning

## Down-regulated aae
## These are the datasets of down-regulated aae enrichment which miRNAs are also found on the up-regulated aal set.
# Per-mirna
aae_per_mirna_up <- read.csv("results/02-enrichment/02-exports-google-sheets/aae-per-mirna-down-stringdb-export.csv")
# All
aae_all_up <- read_csv("results/02-enrichment/02-exports-google-sheets/aae-all-down-stringdb-export.csv")
# aal_per_mirna_all <- read.csv("results/02-enrichment/02-exports-google-sheets/") # this is a future file that will be added

# ==== FUSE DATA ====
# Fuse data frames by row binding
# Per miRNA
per_mirna_stringdb <- rbind(aae_per_mirna_stringdb, aal_per_mirna_stringdb)

# Venny
venny_stringdb <- rbind(aae_venny_stringdb, aal_venny_stringdb)

# All
all_stringdb <- rbind(aae_all_stringdb, aal_all_stringdb)

# ==== VERIFY INTEGRITY OF DATA ====
# Convert dataset column to factors
# Per miRNA
per_mirna_stringdb$dataset <- as.factor(per_mirna_stringdb$dataset)

# Venny
venny_stringdb$dataset <- as.factor(venny_stringdb$dataset)

# All
all_stringdb$dataset <- as.factor(all_stringdb$dataset)

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
    "Local Network Cluster String" = "Local Network Cluster")
  )

# Now get the updated levels to verify
levels_per_mirna_stringdb <- unique(per_mirna_stringdb$dataset)
print(sort(levels_per_mirna_stringdb))

## Venny STRINGDB
levels_venny_stringdb <- unique(venny_stringdb$dataset)
print(sort(levels_venny_stringdb))

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

# ==== SAVE RESULTS TO CSV ====
# Save the fused data frames to .csv files
# Final enriched processes
# Per miRNA
write.csv(per_mirna_stringdb, "results/02-enrichment/03-enrichments-important-process/per-mirna-stringdb.csv", row.names = FALSE)

# Venny
write.csv(venny_stringdb, "results/02-enrichment/03-enrichments-important-process/venny-stringdb.csv", row.names = FALSE)

# All
write.csv(all_stringdb, "results/02-enrichment/03-enrichments-important-process/all-stringdb.csv", row.names = FALSE)

# ==== REMOVE UNEEDED ROWS ====
# NOTE: this part will be optional for now on
# Remove rows that have NA in category_of_interest column

## Per miRNA
# important_per_mirna_stringdb <- per_mirna_stringdb |>
#   filter(!is.na(category_of_interest))
# 
# ## Venny
# important_venny_stringdb <- venny_stringdb |>
#   filter(!is.na(category_of_interest)) # No data available for this dataframe
# 
# ## All
# important_all_stringdb <- all_stringdb |>
#   filter(!is.na(category_of_interest))

# ==== EXPORT IMPORTANT DATA ====
# With category of interes NAs values removed
# Per miRNA
# write.csv(important_per_mirna_stringdb, "results/02-enrichment/03-enrichments-important-process/important-per-mirna-stringdb.csv", row.names = FALSE)
# 
# # Venny
# write.csv(important_venny_stringdb, "results/02-enrichment/03-enrichments-important-process/important-venny-stringdb.csv", row.names = FALSE)
# 
# # All
# write.csv(important_all_stringdb, "results/02-enrichment/03-enrichments-important-process/important-all-stringdb.csv", row.names = FALSE)
