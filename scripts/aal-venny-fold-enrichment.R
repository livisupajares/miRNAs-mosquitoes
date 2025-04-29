# ~~~~~~ FOLD ENRICHMENT ~~~~~
# This script is made to create a dispersion graph of the fold enrichment (SHINYGO & STRINGDB) of ALL Aedes albopictus up-regulated miRNAs with targets.

# Source utils functions and import libraries
library(ggplot2)
library(dplyr)
library(ggrepel)
library(stringr)

# ==== Load enrichment results ====
# Import .csv files
aal_venny_shinygo <- read.csv("results/enrichment/aal/aal-venny_upregulated_shinygo.csv", header = TRUE)

# ==== Fix varible names ====
# Fix column names shinygo
colnames(aal_venny_shinygo) <- c("fdr", "n_genes", "pathway_genes", "fold_enrichment", "pathway", "url", "genes", "dataset")

# ==== Eliminate GO:xxx from pathway ====
# Create the `term_description` variable
aal_venny_shinygo <- aal_venny_shinygo %>%
  mutate(term_description = str_remove(pathway, "^\\S+:\\S+\\s*"))

# ==== Shorten description =====
# truncate long descriptions to first 50 characters
aal_venny_shinygo$short_description <- ifelse(nchar(aal_venny_shinygo$term_description) > 50,
  paste0(substr(aal_venny_shinygo$term_description, 1, 47), "..."),
  aal_venny_shinygo$term_description
)

# ==== Arrange data frame by fold_enrichment/signal =====
aal_venny_shinygo <- aal_venny_shinygo %>%
  arrange(desc(fold_enrichment))

# ==== Make dispersion graphs ====
# Create a color palette for the datasets

# Venny ShinyGO
## Color by fdr
ggplot(aal_venny_shinygo[1:20, ], aes(
  x = fold_enrichment,
  y = reorder(short_description, fold_enrichment),
  color = fdr,
  size = n_genes
)) +
  geom_point() +

  # Gradient color scale for FDR
  scale_color_gradient(low = "red", high = "blue", name = "FDR") +

  # Simplify theme without dynamic y-axis label colors
  ggtitle(stringr::str_wrap("Enrichment Analysis of Aedes albopictus miRNA targets in common with all up-regulated miRNAs - SHINYGO")) +
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
ggplot(aal_venny_shinygo[1:20, ], aes(
  x = fold_enrichment,
  y = reorder(short_description, fold_enrichment),
  color = dataset,
  size = n_genes
)) +
  geom_point() +
  ggtitle(stringr::str_wrap("Enrichment Analysis of Aedes albopictus miRNA targets in common with all up-regulated miRNAs - SHINYGO")) +
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
