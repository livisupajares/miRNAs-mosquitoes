# ~~~~~ PROTEINS OF ENRICHED PROCESES ~~~~~~
# This script splits the genes and pathway_genes into a list of protein ids for each enriched process.
# Then each list is saved into a dataframe with the process name and the list of protein ids.
# Then, the list of protein ids is matched to their names and/or descriptions with imported dataframes of mapped protein ids from ensembl metazoa or stringdb.

# ==== Load libraries ====
library(dplyr)
library(tidyr)

# ==== IMPORT DATA ====
## Import enriched processes data
# Per miRNA
important_per_mirna_shinygo <- read.csv("results/01-enrichment/03-enrichments-important-process/important-per-mirna-shinygo.csv")
important_per_mirna_stringdb <- read.csv("results/01-enrichment/03-enrichments-important-process/important-per-mirna-stringdb.csv")

# Venny
important_venny_shinygo <- read.csv("results/01-enrichment/03-enrichments-important-process/important-venny-shinygo.csv")
important_venny_stringdb <- read.csv("results/01-enrichment/03-enrichments-important-process/important-venny-stringdb.csv")

# All
important_all_shinygo <- read.csv("results/01-enrichment/03-enrichments-important-process/important-all-shinygo.csv")
important_all_stringdb <- read.csv("results/01-enrichment/03-enrichments-important-process/important-all-stringdb.csv")

# Import mapped protein ids from ensembl metazoa
aae_mapped_protein_ids_ensembl <- read.csv("databases/03-enrichment/aae-mapped_shinygo_metazoa.csv")
aal_mapped_protein_ids_ensembl <- read.csv("databases/03-enrichment/aal-mapped_shinygo_metazoa.csv")

# Import mapped protein ids from stringdb
aae_mapped_protein_ids_stringdb <- read.csv("databases/03-enrichment/aae-mapped_stringdb.csv")
aal_mapped_protein_ids_stringdb <- read.csv("databases/03-enrichment/aal-mapped_stringdb.csv")

