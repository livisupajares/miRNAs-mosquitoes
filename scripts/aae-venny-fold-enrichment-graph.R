# ~~~~~~ FOLD ENRICHMENT ~~~~~
# This script is made to create a dispersion graph of the fold enrichment (SHINYGO & STRINGDB) of Aedes aegypti up-regulated miRNAs with common targets calculated by VENNY.

# Source utils functions and import libraries
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

# ==== Make plot graphs ====
# Create a color palette for the datasets

# Venny ShinyGO
# Venny STRINGDB
## Color by fdr, use signal instead of fold_enrichment
ggplot(aae_venny_stringdb, aes(
  x = signal,
  y = reorder(short_description, signal),
  color = fdr,
  size = observed_gene_count
)) +
  geom_point() +

  # Gradient color scale for FDR
  scale_color_gradient(low = "blue", high = "red", name = "FDR") +

  # Simplify theme without dynamic y-axis label colors
  ggtitle(stringr::str_wrap("Enrichment Analysis of Aedes aegypti miRNA targets in common with all up-regulated miRNAs - STRINGDB")) +
  theme(
    axis.text.y = element_text(size = 10), # Smaller y-axis text
    axis.text.x = element_text(size = 10), # Smaller x-axis numbers
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
    legend.position = "right"
  ) +
  labs(
    x = "Signal",
    y = "Term Description",
    size = "Gene Count"
  ) +

  # Add x-axis breaks every 50
  scale_x_continuous(breaks = seq(0, 2, by = 0.25))

## Color by dataset
ggplot(aae_venny_stringdb, aes(
  x = signal,
  y = reorder(short_description, signal),
  color = dataset,
  size = observed_gene_count
)) +
  geom_point() +
  ggtitle(stringr::str_wrap("Enrichment Analysis of Aedes aegypti miRNA targets in common with all up-regulated miRNAs - STRINGDB")) +
  theme(
    axis.text.y = element_text(size = 10), # Smaller y-axis text
    axis.text.x = element_text(size = 10), # Smaller x-axis numbers
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
    legend.position = "right"
  ) +
  labs(
    x = "Signal",
    y = "Term Description",
    size = "Gene Count"
  ) +

  # Add x-axis breaks every 50
  scale_x_continuous(breaks = seq(0, 2, by = 0.25))

## Scatterplot
# scatterplot colored by dataset
ggplot(
  aae_venny_stringdb,
  aes(
    x = strength,
    y = signal,
    color = dataset,
    size = observed_gene_count
  )
) +
  geom_text_repel(
    aes(label = short_description),
    size = 3, # Adjust label size
    box.padding = 0.5, # Space around labels
    point.padding = 0.5, # Space around points
    force = 1, # Increase from the default to strengthen repulsion
    max.overlaps = 5, # Allow up to 5 overlap per label
    min.segment.length = 0, # Connect labels to points with lines
    segment.color = "grey50" # Line color connecting labels to points
  ) +
  geom_point() +
  ggtitle(stringr::str_wrap("Scatterplot of Fold Enrichment vs Strength - Enrichment Analysis of Aedes aegypti miRNA targets in common with all up-regulated miRNAs - STRINGDB", width = 80)) +
  theme(
    axis.text.y = element_text(size = 10), # Smaller y-axis text
    axis.text.x = element_text(size = 10), # Smaller x-axis numbers
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
    legend.position = "right"
  ) +
  labs(
    x = "Strength (Log10(observed / expected))",
    y = "Signal",
    size = "Gene Count"
  )
