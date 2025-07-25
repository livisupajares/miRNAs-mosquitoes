# ~~~~~~ FOLD ENRICHMENT ~~~~~
# This script is made to create a dispersion graph of the fold enrichment (SHINYGO & STRINGDB) of ALL Aedes aegypti up-regulated miRNAs with targets.

# Source utils functions and import libraries
library(ggplot2)
library(dplyr)
library(ggrepel)
library(stringr)

# ==== Load enrichment results ====
## Import .csv files
# All before filtering
all_shinygo <- read.csv("results/01-enrichment/03-enrichments-important-process/all-shinygo.csv", header = TRUE)
all_stringdb <- read.csv("results/01-enrichment/03-enrichments-important-process/all-stringdb.csv", header = TRUE)

# All after filtering
filt_all_shinygo <- read.csv("results/01-enrichment/03-enrichments-important-process/important-all-shinygo.csv", header = TRUE)
filt_all_stringdb <- read.csv("results/01-enrichment/03-enrichments-important-process/important-all-stringdb.csv", header = TRUE)

# ==== Eliminate GO:xxx from pathway ====
## Create the `term_description` variable
# All before filtering
all_shinygo <- all_shinygo %>%
  mutate(term_description = str_remove(pathway, "^\\S+:\\S+\\s*"))

# All after filtering
filt_all_shinygo <- filt_all_shinygo %>%
  mutate(term_description = str_remove(pathway, "^\\S+:\\S+\\s*"))

# ==== Shorten description =====
# truncate long descriptions to first 50 characters

## SHINYGO
# All before filtering
all_shinygo$short_description <- ifelse(nchar(all_shinygo$term_description) > 50,
  paste0(substr(all_shinygo$term_description, 1, 47), "..."),
  all_shinygo$term_description
)

# All after filtering
filt_all_shinygo$short_description <- ifelse(nchar(filt_all_shinygo$term_description) > 50,
  paste0(substr(filt_all_shinygo$term_description, 1, 47), "..."),
  filt_all_shinygo$term_description
)

## STRINGDB
# All before filtering
all_stringdb$short_description <- ifelse(nchar(all_stringdb$term_description) > 50,
  paste0(substr(all_stringdb$term_description, 1, 47), "..."),
  all_stringdb$term_description
)

# All after filtering
filt_all_stringdb$short_description <- ifelse(nchar(filt_all_stringdb$term_description) > 50,
  paste0(substr(filt_all_stringdb$term_description, 1, 47), "..."),
  filt_all_stringdb$term_description
)

# ==== Arrange data frame by fold_enrichment/signal =====
## SHINYGO
# All before filtering
all_shinygo <- all_shinygo %>%
  group_by(species) %>%
  arrange(desc(fold_enrichment), .by_group = TRUE)

# All after filtering
filt_all_shinygo <- filt_all_shinygo %>%
  group_by(species) %>%
  arrange(desc(fold_enrichment), .by_group = TRUE)

## STRING DB
# All before filtering
all_stringdb <- all_stringdb %>%
  group_by(species) %>%
  arrange(desc(signal), .by_group = TRUE)

# All after filtering
filt_all_stringdb <- filt_all_stringdb %>%
  group_by(species) %>%
  arrange(desc(signal), .by_group = TRUE)

# ==== Make dispersion graphs ====
### All before filtering
## ShinyGO
# Color by fdr
# You can change the species name to "Aedes aegypti" or "Aedes albopictus"
ggplot(data = filter(all_shinygo, species == "Aedes aegypti"), aes(
  x = fold_enrichment,
  y = reorder(short_description, fold_enrichment),
  color = enrichment_fdr,
  size = n_genes
)) +
  geom_point() +

  # Gradient color scale for FDR
  scale_color_gradient(low = "red", high = "blue", name = "FDR") +

  # Simplify theme without dynamic y-axis label colors
  ggtitle(stringr::str_wrap("Enrichment Analysis of Aedes aegypti miRNA targets in all up-regulated miRNAs - SHINYGO")) +
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

# All after filtering
# You can change the species name to "Aedes aegypti" or "Aedes albopictus"
ggplot(data = filter(filt_all_shinygo, species == "Aedes aegypti"), aes(
  x = fold_enrichment,
  y = reorder(short_description, fold_enrichment),
  color = enrichment_fdr,
  size = n_genes
)) +
  geom_point() +

  # Gradient color scale for FDR
  scale_color_gradient(low = "red", high = "blue", name = "FDR") +

  # Simplify theme without dynamic y-axis label colors
  ggtitle(stringr::str_wrap("Enrichment Analysis of Aedes aegypti miRNA targets in all up-regulated miRNAs - SHINYGO")) +
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
ggplot(data = filter(all_shinygo, species == "Aedes aegypti"), aes(
  x = fold_enrichment,
  y = reorder(short_description, fold_enrichment),
  color = dataset,
  size = n_genes
)) +
  geom_point() +
  ggtitle(stringr::str_wrap("Enrichment Analysis of Aedes aegypti miRNA targets in all up-regulated miRNAs - SHINYGO")) +
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

# Venny STRINGDB
## Color by fdr
ggplot(aae_all_stringdb[1:20, ], aes(
  x = signal,
  y = reorder(short_description, signal),
  color = fdr,
  size = observed_gene_count
)) +
  geom_point() +

  # Gradient color scale for FDR
  scale_color_gradient(low = "red", high = "blue", name = "FDR") +

  # Simplify theme without dynamic y-axis label colors
  ggtitle(stringr::str_wrap("Enrichment Analysis of Aedes aegypti miRNA targets in all up-regulated miRNAs - STRINGDB")) +
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
  )

## Color by dataset
ggplot(aae_all_stringdb[1:20, ], aes(
  x = signal,
  y = reorder(short_description, signal),
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
    x = "Signal",
    y = "Term Description",
    size = "Gene Count"
  )

## Scatterplot
# scatterplot colored by dataset
ggplot(
  aae_all_stringdb,
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
  ggtitle(stringr::str_wrap("Scatterplot of Fold Enrichment vs Strength - Enrichment Analysis of Aedes aegypti miRNA targets in all up-regulated miRNAs - STRINGDB", width = 80)) +
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
