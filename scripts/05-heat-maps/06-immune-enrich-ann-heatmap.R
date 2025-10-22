# ~~~~ IMMUNE RELATED ENRICHMRNT ANNOTATIONS ~~~~
# This script will filter from `all_ann` and `per_mirna_ann` enriched processes related to immune category. Then it will use uniprot ids a heatmap columns instead of miRNAs.

# ===== Add libraries =====
library(tidyverse)
# library(tidyheatmaps)
# library(ComplexHeatmap)
# library(circlize)
library(tidylog, warn.conflicts = FALSE)

# ==== UPLOAD DATA ====
# Per-mirna
per_mirna_ann <- read.csv(
  "results/04-heatmap/final_ann_per_mirna.csv"
)

## Compute -log10(FDR) for plotting
per_mirna_ann <- per_mirna_ann |>
  mutate(log10_fdr = -log10(false_discovery_rate))

## Wrap term descriptions to, say, 30 characters per line
per_mirna_ann <- per_mirna_ann %>%
  mutate(term_wrapped = str_wrap(term_description, width = 30))

# All
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

# ==== FILTER BY IMMUNE ENRICHMENT=====
## Filter immune only data
per_mirna_ann_immune <- per_mirna_ann |>
  filter(category_of_interest == "immune")
all_ann_immune <- all_ann |>
  filter(category_of_interest == "immune")

# ==== HEATMAPS =====
# ==== PER-MIRNA BY SPECIES ====
ggplot(per_mirna_ann_immune, aes(x = uniprot_id, y = term_wrapped, fill = log10_fdr)) +
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
  labs(title = "Immune-Related Enrichments (per-mirna) by Species",
       x = "uniprot_id",
       y = "term description",
       fill = "-log10(FDR")

# ==== ALL BY SPECIES ====
# heatplot is too messy
# ggplot(all_ann_immune, aes(x = uniprot_id, y = term_wrapped, fill = log10_fdr)) +
#   geom_tile(color = "white") +
#   facet_wrap(~ species, scales = "free_y") +
#   scale_fill_viridis_c(
#     option = "plasma",      # or "plasma", "inferno", "viridis"
#     direction = -1,        # darker = more significant (higher -log10(FDR))
#     na.value = "grey90",
#     name = "-log10(FDR)"
#   ) +
#   theme_minimal(base_size = 10) +
#   theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
#   labs(title = "Immune-Related Enrichments (all) by Species",
#        x = "uniprot_id",
#        y = "term description",
#        fill = "-log10(FDR")
