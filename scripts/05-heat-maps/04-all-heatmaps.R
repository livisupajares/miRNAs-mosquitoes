# ~~~~  HEATMAPS ~~~~~
# This script will create heatmaps to visualize data from enrichments and annotations of enriched miRNA targets up-regulated (and some down-regulated in common)

# ===== Add libraries =====
library(tidyverse)
# library(tidyheatmaps)
# library(ComplexHeatmap)
# library(circlize)
library(tidylog, warn.conflicts = FALSE)

# ==== ALL =====
# all annotation
all_ann <- read.csv(
  "results/04-heatmap/final_ann_all.csv"
)

## Compute -log10(FDR) for plotting
all_ann <- all_ann |>
  mutate(log10_fdr = -log10(false_discovery_rate))

## Wrap term descriptions to, say, 30 characters per line
all_ann <- all_ann %>%
  mutate(term_wrapped = str_wrap(term_description, width = 30))

# All enrichments only
all_en <- read.csv(
  "results/04-heatmap/final_enrichment_all.csv"
)

## Compute -log10(FDR) for plotting
all_en <- all_en |>
  mutate(log10_fdr = -log10(false_discovery_rate))

## Wrap term descriptions to, say, 30 characters per line
all_en <- all_en %>%
  mutate(term_wrapped = str_wrap(term_description, width = 30))

# ==== HEATMAP ALL ====
# ==== TOP 10 ENRICHMENTS GROUPED BY MIRNA EXPRESSION AND BY SPECIES =====
## Filter top 5 in Aedes aegypti / 2 in Aedes albopictus
all_en_5 <- all_en |>
  group_by(species) |>
  slice_max(order_by = log10_fdr, n = 5)

## Filter top 5 down-regulated in Aedes aegypti
aae_all_down_5 <- all_en |>
  filter(mirna_expression == "down-regulated",
         species == "Aedes aegypti") |>
  slice_max(log10_fdr, n = 5, with_ties = FALSE)

## Merge both data frames
all_en_10 <- bind_rows(
  all_en_5,
  aae_all_down_5
)

## Top 10 data by species
ggplot(all_en_10, aes(x = mirna_expression, y = term_wrapped, fill = log10_fdr)) +
  geom_tile(color = "white") +
  facet_wrap(~ species, scales = "free_y") +
  scale_fill_viridis_c(
    option = "plasma",      # or "plasma", "inferno", "viridis"
    direction = -1,        # darker = more significant (higher -log10(FDR))
    na.value = "grey90",
    name = "-log10(FDR)"
  ) +
  theme_minimal(base_size = 10) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Top 10 Significant Enrichments (all) per Species",
       x = "miRNA expression",
       y = "term description",
       fill = "-log10(FDR")

# ==== IMMUNE RELATED ENRICHMENTS BY SPECIES GROUPED BY MIRNA EXPRESSION ====
## Filter immune related enrichments
all_ann_immune <- all_ann |>
  filter(category_of_interest == "immune")

ggplot(all_ann_immune, aes(x = mirna_expression, y = term_wrapped, fill = log10_fdr)) +
  geom_tile(color = "white") +
  facet_wrap(~ species, scales = "free_y") +
  scale_fill_viridis_c(
    option = "plasma",      # or "plasma", "inferno", "viridis"
    direction = -1,        # darker = more significant (higher -log10(FDR))
    na.value = "grey90",
    name = "-log10(FDR)"
  ) +
  theme_minimal(base_size = 10) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Immune-Related Enrichments by miRNA expression and Species",
       x = "miRNA expression",
       y = "term description",
       fill = "-log10(FDR")
