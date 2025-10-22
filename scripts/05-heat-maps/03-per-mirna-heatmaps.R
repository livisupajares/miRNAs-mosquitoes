# ~~~~  HEATMAPS ~~~~~
# This script will create heatmaps to visualize data from enrichments and annotations of enriched miRNA targets up-regulated (and some down-regulated in common)
 
# ===== Add libraries =====
library(tidyverse)
# library(tidyheatmaps)
# library(ComplexHeatmap)
# library(circlize)
library(tidylog, warn.conflicts = FALSE)

# ===== Import data =====
# ==== Per-miRNA =====
# Per-mirna annotation
per_mirna_ann <- read.csv(
  "results/04-heatmap/final_ann_per_mirna.csv"
)

## Compute -log10(FDR) for plotting
per_mirna_ann <- per_mirna_ann |>
  mutate(log10_fdr = -log10(false_discovery_rate))

## Wrap term descriptions to, say, 30 characters per line
per_mirna_ann <- per_mirna_ann %>%
  mutate(term_wrapped = str_wrap(term_description, width = 30))

# Per-mirna enrichments only
per_mirna_en <- read.csv(
  "results/04-heatmap/final_enrichment_per_mirna.csv"
)
## Compute -log10(FDR) for plotting
per_mirna_en <- per_mirna_en |>
  mutate(log10_fdr = -log10(false_discovery_rate))

## Wrap term descriptions to, say, 30 characters per line
per_mirna_en <- per_mirna_en %>%
  mutate(term_wrapped = str_wrap(term_description, width = 30))


# ==== HEATMAP PER MIRNA ====
# ===== TOP 10 ENRICHMENTS BY SPECIES ====
## Filter top 10
per_mirna_en_10 <- per_mirna_en |>
  group_by(species) |>
  slice_max(order_by = log10_fdr, n = 10)

## Top 10 data by species
ggplot(per_mirna_en_10, aes(x = mirna, y = term_wrapped, fill = log10_fdr)) +
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
  labs(title = "Top 10 Significant Enrichments by miRNA (per-miRNA) and Species",
       x = "miRNA",
       y = "term description",
       fill = "-log10(FDR")

# ==== TOP 10 ENRICHMENTS OF COMMON MIRNAS BY SPECIES ====
## Filter common miRNAs and get top 10 enrichments
# Split by species and process
aae_common10 <- per_mirna_en %>%
  filter(
    common_mirna == "yes",
    species == "Aedes aegypti"
  ) %>%
  slice_max(log10_fdr, n = 10, with_ties = FALSE)

aal_common <- per_mirna_en %>%
  filter(
    common_mirna == "yes",
    species == "Aedes albopictus"
  )

# Combine both species
per_mirna_common_10 <- bind_rows(
  aae_common10,
  aal_common
)

## Common miRNAs by species
ggplot(per_mirna_common_10, aes(x = mirna, y = term_wrapped, fill = log10_fdr)) +
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
  labs(title = "Top 10 Enrichments found in common miRNA (per-miRNA) by Species",
       x = "miRNA",
       y = "term description",
       fill = "-log10(FDR")

# ===== TOP 10 ENRICHMENTS BY MIRNA EXPRESSION ====
## Filter by top 10 (mirna_expression)
# UP-REGULATED: 5 from each species 
up_per_mirna <- per_mirna_en %>%
  filter(mirna_expression == "up-regulated") %>%
  group_by(species) %>%
  slice_max(log10_fdr, n = 5, with_ties = FALSE) %>%
  ungroup()

# DOWN-REGULATED: top 10 from Aedes aegypti only 
down_per_mirna_aae <- per_mirna_en %>%
  filter(
    mirna_expression == "down-regulated",
    species == "Aedes aegypti"
  ) %>%
  slice_max(log10_fdr, n = 10, with_ties = FALSE)

# COMBINE 
per_mirna_exp_10 <- bind_rows(up_per_mirna, down_per_mirna_aae)

## By mirna_expression
ggplot(per_mirna_exp_10, aes(x = mirna, y = term_wrapped, fill = log10_fdr)) +
  geom_tile(color = "white") +
  facet_wrap(~ mirna_expression, scales = "free_y") +
  scale_fill_viridis_c(
    option = "plasma",      # or "plasma", "inferno", "viridis"
    direction = -1,        # darker = more significant (higher -log10(FDR))
    na.value = "grey90",
    name = "-log10(FDR)"
  ) +
  theme_minimal(base_size = 10) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Enrichments by miRNA expression (per-miRNA)",
       x = "miRNA",
       y = "term description",
       fill = "-log10(FDR")

# ==== IMMUNE RELATED ENRICHMENTS BY SPECIES ====
## Filter immune only data
per_mirna_ann_immune <- per_mirna_ann |>
  filter(category_of_interest == "immune")

## By species (immune)
ggplot(per_mirna_ann_immune, aes(x = mirna, y = term_wrapped, fill = log10_fdr)) +
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
  labs(title = "Immune-Related Enrichments by miRNA (per-miRNA) and Species",
       x = "miRNA",
       y = "term description",
       fill = "-log10(FDR")
