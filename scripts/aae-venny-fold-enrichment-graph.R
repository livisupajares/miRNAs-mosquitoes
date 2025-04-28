# ~~~~~~ FOLD ENRICHMENT ~~~~~
# This script is made to create a dispersion graph of the fold enrichment (SHINYGO & STRINGDB) of Aedes aegypti up-regulated miRNAs with common targets calculated by VENNY.

# Source utils functions and import libraries
source("scripts/functions.R")
library(ggplot2)
library(dplyr)
library(ggrepel)

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

# ==== Add fold_enrichment_column =====
# Add fold_enrichment column to stringdb and calculate fold enrichment from strength values
aae_venny_stringdb$fold_enrichment <- calculate_fold_enrichment(aae_venny_stringdb$strength)

# ==== Make dispersion graphs ====
# Create a color palette for the datasets

# Venny ShinyGO
# Venny STRINGDB
## Color by fdr/signal
ggplot(aae_venny_stringdb, aes(
  x = fold_enrichment,
  y = reorder(short_description, fold_enrichment),
  color = signal,
  size = observed_gene_count
)) +
  geom_point() +

  # Gradient color scale for FDR
  scale_color_gradient(low = "red", high = "blue", name = "Signal -Log(FDR)") +

  # Simplify theme without dynamic y-axis label colors
  ggtitle(stringr::str_wrap("Enrichment Analysis of Aedes aegypti miRNA targets in common with all up-regulated miRNAs - STRINGDB")) +
  theme(
    axis.text.y = element_text(size = 10), # Smaller y-axis text
    axis.text.x = element_text(size = 10), # Smaller x-axis numbers
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
    legend.position = "right"
  ) +
  labs(
    x = "Fold Enrichment",
    y = "Term Description",
    size = "Gene Count"
  ) +

  # Add x-axis breaks every 50
  scale_x_continuous(breaks = seq(0, 550, by = 50))

## Color by dataset
ggplot(aae_venny_stringdb, aes(
  x = fold_enrichment,
  y = reorder(short_description, fold_enrichment),
  color = dataset,
  size = observed_gene_count
)) +
  geom_point() +
  ggtitle(stringr::str_wrap("Enrichment Analysis of Aedes aegypti miRNA targets in common with all up-regulated miRNAs - STRINGDB")) +
  )
