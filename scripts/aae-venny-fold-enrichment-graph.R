# ~~~~~~ FOLD ENRICHMENT ~~~~~
# This script is made to create a dispersion graph of the fold enrichment (SHINYGO & STRINGDB) of Aedes aegypti up-regulated miRNAs with common targets calculated by VENNY.

# Source utils functions and import libraries
source("scripts/functions.R")
library(ggplot2)
library(ggfittext) # Package to adjust text into ggplot2 plots

# ==== Load enrichment results ====
# Import .csv files
aae_venny_shinygo <- read.csv("results/enrichment/aae/aae-venny_upregulated_shinygo.csv", header = TRUE)
aae_venny_stringdb <- read.csv("results/enrichment/aae/aae-venny_upregulated_stringdb.csv", header = TRUE)

# ==== Fix varible names ====
# Fix column names shinygo
colnames(aae_venny_shinygo) <- c("fdr", "n_genes", "pathway_genes", "fold_enrichment", "pathway", "url", "genes", "dataset")

# Fix column names stringdb
colnames(aae_venny_stringdb) <- c("term_id", "term_description", "observed_gene_count", "background_gene_count", "strength", "signal", "fdr", "matching_proteins_in_your_network_IDs", "matching_proteins_in_your_network_labels", "dataset")

# ==== Shorten description =====
# truncate long descriptions to first 50 characters
aae_venny_stringdb$short_description <- ifelse(nchar(aae_venny_stringdb$term_description) > 50,
  paste0(substr(aae_venny_stringdb$term_description, 1, 47), "..."),
  aae_venny_stringdb$term_description
)

# ==== Make combined labels for STRINGDB ====
# Make combined labels: dataset + short description
# aae_venny_stringdb$dataset_short_desc <- paste0(aae_venny_stringdb$dataset, " | ", aae_venny_stringdb$short_description)

