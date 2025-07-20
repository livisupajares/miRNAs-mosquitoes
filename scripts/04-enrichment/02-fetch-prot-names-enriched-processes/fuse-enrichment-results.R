# ~~~~~ FUSE ENRICHMENT RESULTS ~~~~~
# This script is used to fuse the enrichment results so at the end, we will get
# per-mirna stringdb, per-mirna shinygo, venny stringdb, venny shinygo, all stringdb, all shinygo, where each will have Aedes aegypti and Aedes albopictus.
# ==== Load libraries ====
library(dplyr)
library(forcats)
library(stringr)

# ==== IMPORT DATABASES TO BE FUSED ====
## Per miRNA
# Per-mirna shinygo
aae_per_mirna_shinygo <- read.csv("results/01-enrichment/02-exports-google-sheets/aae-per-mirna-shinygo-export.csv")
aal_per_mirna_shinygo <- read.csv("results/01-enrichment/02-exports-google-sheets/aal-per-mirna-shinygo-export.csv")
# Per mirna stringdb
aae_per_mirna_stringdb <- read.csv("results/01-enrichment/02-exports-google-sheets/aae-per-mirna-stringdb-export.csv")
aal_per_mirna_stringdb <- read.csv("results/01-enrichment/02-exports-google-sheets/aal-per-mirna-stringdb-export.csv")

## Venny
# Venny shinygo
aae_venny_shinygo <- read.csv("results/01-enrichment/02-exports-google-sheets/aae-venny-shinygo-export.csv")
aal_venny_shinygo <- read.csv("results/01-enrichment/02-exports-google-sheets/aal-venny-shinygo-export.csv")
# Venny stringdb
aae_venny_stringdb <- read.csv("results/01-enrichment/02-exports-google-sheets/aae-venny-stringdb-export.csv")
aal_venny_stringdb <- read.csv("results/01-enrichment/02-exports-google-sheets/aal-venny-stringdb-export.csv") # No significant enriched processes were found. No data. Ignore warning

## All
# All shinygo
aae_all_shinygo <- read.csv("results/01-enrichment/02-exports-google-sheets/aae-all-shinygo-export.csv")
aal_all_shinygo <- read.csv("results/01-enrichment/02-exports-google-sheets/aal-all-shinygo-export.csv")
# All stringdb
aae_all_stringdb <- read.csv("results/01-enrichment/02-exports-google-sheets/aae-all-stringdb-export.csv")
aal_all_stringdb <- read.csv("results/01-enrichment/02-exports-google-sheets/aal-all-stringdb-export.csv")

# ==== FUSE DATA ====
# Fuse data frames by row binding
# Per miRNA
per_mirna_shinygo <- rbind(aae_per_mirna_shinygo, aal_per_mirna_shinygo)
per_mirna_stringdb <- rbind(aae_per_mirna_stringdb, aal_per_mirna_stringdb)

# Venny
venny_shinygo <- rbind(aae_venny_shinygo, aal_venny_shinygo)
venny_stringdb <- rbind(aae_venny_stringdb, aal_venny_stringdb)

# All
all_shinygo <- rbind(aae_all_shinygo, aal_all_shinygo)
all_stringdb <- rbind(aae_all_stringdb, aal_all_stringdb)

# ==== VERIFY INTEGRITY OF DATA ====
# Convert dataset column to factors
# Per miRNA
per_mirna_shinygo$dataset <- as.factor(per_mirna_shinygo$dataset)
per_mirna_stringdb$dataset <- as.factor(per_mirna_stringdb$dataset)

# Venny
venny_shinygo$dataset <- as.factor(venny_shinygo$dataset)
venny_stringdb$dataset <- as.factor(venny_stringdb$dataset)

# All
all_shinygo$dataset <- as.factor(all_shinygo$dataset)
all_stringdb$dataset <- as.factor(all_stringdb$dataset)

# Make sure each dataset column has unique levels with no misspelling/duplication
## Per miRNA
# Get unique levels of dataset
levels_per_mirna_shinygo <- unique(per_mirna_shinygo$dataset)
print(sort(levels_per_mirna_shinygo))
levels_per_mirna_stringdb <- unique(per_mirna_stringdb$dataset)
print(sort(levels_per_mirna_stringdb))

# Merge levels if they are misspelled duplicates using the forcats package
# This is done to ensure that the levels are consistent across datasets.
per_mirna_stringdb <- per_mirna_stringdb |>
  mutate(dataset = fct_collapse(dataset,
    # Merge Reactome levels
    "Reactome Pathway" = c("Reactome Pathway", "Reactome Pathways"),

    # Merge Local Network Cluster variants
    "Local Network Cluster String" = c(
      "Local Network Cluster (STRING)",
      "Local Network Cluster String",
      "Local Network Cluster"
    )
  ))

# Now get the updated levels to verify
levels_per_mirna_stringdb <- unique(per_mirna_stringdb$dataset)
print(sort(levels_per_mirna_stringdb))

## Venny
# Get unique levels of dataset
levels_venny_shinygo <- unique(venny_shinygo$dataset)
print(sort(levels_venny_shinygo))
levels_venny_stringdb <- unique(venny_stringdb$dataset)
print(sort(levels_venny_stringdb))

# Change level names if they are misspelled duplicates using the forcats package
# This is done to ensure that the levels are consistent across datasets.
venny_stringdb <- venny_stringdb %>%
  mutate(dataset = fct_recode(dataset,
    "Local Network Cluster String" = "Local Network Cluster"
  ))

# Now get the updated levels to verify
levels_venny_stringdb <- unique(venny_stringdb$dataset)
print(sort(levels_venny_stringdb))

## All
# Get unique levels of dataset
levels_all_shinygo <- unique(all_shinygo$dataset)
print(sort(levels_all_shinygo))
levels_all_stringdb <- unique(all_stringdb$dataset)
print(sort(levels_all_stringdb))

# Change level names if they are misspelled duplicates using the forcats package
# This is done to ensure that the levels are consistent across datasets.
all_stringdb <- all_stringdb %>%
  mutate(dataset = fct_recode(dataset,
    "Local Network Cluster String" = "Local Network Cluster"
  ))

# Now get the updated levels to verify
levels_all_stringdb <- unique(all_stringdb$dataset)
print(sort(levels_all_stringdb))

# ==== SAVE RESULTS TO CSV ====
# Save the fused data frames to .csv files
# Per miRNA
write.csv(per_mirna_shinygo, "results/01-enrichment/03-enrichments-important-process/per-mirna-shinygo.csv", row.names = FALSE)

write.csv(per_mirna_stringdb, "results/01-enrichment/03-enrichments-important-process/per-mirna-stringdb.csv", row.names = FALSE)

# Venny
write.csv(venny_shinygo, "results/01-enrichment/03-enrichments-important-process/venny-shinygo.csv", row.names = FALSE)

write.csv(venny_stringdb, "results/01-enrichment/03-enrichments-important-process/venny-stringdb.csv", row.names = FALSE)

# All
write.csv(all_shinygo, "results/01-enrichment/03-enrichments-important-process/all-shinygo.csv", row.names = FALSE)

write.csv(all_stringdb, "results/01-enrichment/03-enrichments-important-process/all-stringdb.csv", row.names = FALSE)

# ==== REMOVE UNEEDED ROWS ====
# Remove rows that have NA in category_of_interest column

## Per miRNA
important_per_mirna_shinygo <- per_mirna_shinygo |>
  filter(!is.na(category_of_interest))

important_per_mirna_stringdb <- per_mirna_stringdb |>
  filter(!is.na(category_of_interest))

# Remove rows that have only one gene code such as "RP20_CCG004523" or "CCG017659.2" and not "CCG001475.1 CCG012626.1" or "CCG007937.2 RP20_CCG008969.2 CCG020002.2" in the genes column
# This is done so we don't get enriched terms that only mach one gene/protein from our set
important_per_mirna_shinygo <- important_per_mirna_shinygo |>
  filter(str_count(genes, "\\S+") >= 2) # Keep rows with two or more gene

# Replace entire column with "STRINGv12.0"
important_per_mirna_stringdb$protein_db <- "STRINGv12.0"

## Venny
important_venny_shinygo <- venny_shinygo |>
  filter(!is.na(category_of_interest)) # No data available for this dataframe

important_venny_stringdb <- venny_stringdb |>
  filter(!is.na(category_of_interest))

## All
important_all_shinygo <- all_shinygo |>
  filter(!is.na(category_of_interest))

important_all_stringdb <- all_stringdb |>
  filter(!is.na(category_of_interest))

# ==== EXPORT IMPORTANT DATA ====
# Per miRNA
write.csv(important_per_mirna_shinygo, "results/01-enrichment/03-enrichments-important-process/important-per-mirna-shinygo.csv", row.names = FALSE)
write.csv(important_per_mirna_stringdb, "results/01-enrichment/03-enrichments-important-process/important-per-mirna-stringdb.csv", row.names = FALSE)

# Venny
write.csv(important_venny_shinygo, "results/01-enrichment/03-enrichments-important-process/important-venny-shinygo.csv", row.names = FALSE)
write.csv(important_venny_stringdb, "results/01-enrichment/03-enrichments-important-process/important-venny-stringdb.csv", row.names = FALSE)

# All
write.csv(important_all_shinygo, "results/01-enrichment/03-enrichments-important-process/important-all-shinygo.csv", row.names = FALSE)
write.csv(important_all_stringdb, "results/01-enrichment/03-enrichments-important-process/important-all-stringdb.csv", row.names = FALSE)
