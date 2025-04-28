# ~~~~~~ FOLD ENRICHMENT ~~~~~
# This script is made to create a dispersion graph of the fold enrichment (SHINYGO & STRINGDB) of ALL Aedes albopictus up-regulated miRNAs with targets.

# Source utils functions and import libraries
source("scripts/functions.R")
library(ggplot2)
library(dplyr)
library(ggrepel)

# ==== Load enrichment results ====
# Import .csv files
aal_all_shinygo <- read.csv("results/enrichment/aal/aal-upregulated_miranda_ALL-shinygo.csv", header = TRUE)
aal_all_stringdb <- read.csv("results/enrichment/aal/aal-upregulated_miranda_ALL_stringdb.csv", header = TRUE)

# ==== Fix varible names ====
# Fix column names shinygo
colnames(aal_all_shinygo) <- c("fdr", "n_genes", "pathway_genes", "fold_enrichment", "pathway", "url", "genes", "dataset")

# Fix column names stringdb
colnames(aal_all_stringdb) <- c("term_id", "term_description", "observed_gene_count", "background_gene_count", "strength", "signal", "fdr", "matching_proteins_in_your_network_IDs", "matching_proteins_in_your_network_labels", "dataset")

# ==== Shorten description =====
# truncate long descriptions to first 50 characters
aal_all_stringdb$short_description <- ifelse(nchar(aal_all_stringdb$term_description) > 50,
  paste0(substr(aal_all_stringdb$term_description, 1, 47), "..."),
  aal_all_stringdb$term_description
)

# ==== Add fold_enrichment_column =====
# Add fold_enrichment column to stringdb and calculate fold enrichment from strength values
aal_all_stringdb$fold_enrichment <- calculate_fold_enrichment(aal_all_stringdb$strength)

# Calculate observed/expected ratio
aal_all_stringdb$observed_expected_ratio <- aal_all_stringdb$observed_gene_count / aal_all_stringdb$background_gene_count

# Arrange the data frame by fold_enrichment in descending order
aal_all_stringdb <- aal_all_stringdb %>%
  arrange(desc(fold_enrichment))

# ==== Make dispersion graphs ====
# Create a color palette for the datasets

# Venny ShinyGO
# Venny STRINGDB
## Color by fdr/signal
ggplot(aae_all_stringdb[1:20, ], aes(
  x = fold_enrichment,
  y = reorder(short_description, fold_enrichment),
  color = signal,
  size = observed_gene_count
)) +
  geom_point() +

  # Gradient color scale for FDR
  scale_color_gradient(low = "red", high = "blue", name = "Signal -Log(FDR)") +

  # Simplify theme without dynamic y-axis label colors
  ggtitle(stringr::str_wrap("Enrichment Analysis of Aedes aegypti miRNA targets in all up-regulated miRNAs - STRINGDB")) +
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
  )

## Color by dataset
ggplot(aae_all_stringdb[1:20, ], aes(
  x = fold_enrichment,
  y = reorder(short_description, fold_enrichment),
  color = dataset,
  size = observed_gene_count
)) +
  geom_point() +
  ggtitle(stringr::str_wrap("Enrichment Analysis of Aedes aegypti miRNA targets in all up-regulated miRNAs - STRINGDB")) +
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
  )

## Scatterplot
# scatterplot colored by dataset
ggplot(
  aae_all_stringdb,
  aes(
    x = strength,
    y = fold_enrichment,
    color = dataset,
    size = observed_gene_count
  )
) +
  geom_text_repel(
    aes(label = short_description),
    size = 3, # Adjust label size
    box.padding = 0.5, # Space around labels
    point.padding = 0.5, # Space around points
    force = 5, # Increase from the default to strengthen repulsion
    max.overlaps = 5, # Allow up to 5 overlap per label
    min.segment.length = 0, # Connect labels to points with lines
    segment.color = "grey50" # Line color connecting labels to points
  ) +
  geom_point() +
  ggtitle(stringr::str_wrap("Scatterplot of Fold Enrichment vs Strength - Enrichment Analysis of Aedes aegypti miRNA targets in all up-regulated miRNAs - STRINGDB", width = 80)) +
  theme(
    axis.text.y = element_text(size = 10), # Smaller y-axis text
    axis.text.x = element_text(size = 10), # Smaller x-axis numbers
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
    legend.position = "right"
  ) +
  labs(
    x = "Strength (Log10(observed / expected))",
    y = "Fold Enrichment (10^strength)",
    size = "Gene Count"
  )
