# ~~~~  HEATMAPS IMMUNE PER TARGET~~~~~
# This script will create heatmaps to visualize data from enrichments and annotations of enriched miRNA targets up-regulated (and some down-regulated in common)

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

# ==== FILTER BY IMMUNE ANNOTATIONS =====
# Keep rows that contain immune related words inside the annotation variables
# Define immune keywords (as a regex pattern)
immune_keywords <- c(
  "immunoglobulin",
  "TOLL",
  "Toll",
  "programmed cell death",
  "interleukin",
  "apoptotic process",
  "apoptosis",
  "phagocytosis",
  "Toll/interleukin",
  "Toll-like",
  "hematopoietic"
)

# Add a regex pattern for "IL" that matches:
# - "IL" at word boundary (e.g., "IL", "IL,", "IL.")
# - "IL-" followed by anything (e.g., "IL-1", "IL-17A", "IL-6R")
# We'll combine this with the other terms using regex OR (|)
immune_pattern <- paste(
  # Escape and paste the regular terms
  paste(
    immune_keywords %>%
      str_replace_all("([.^$|()\\[\\]{}*+?\\\\])", "\\\\$1"),  # escape regex metacharacters
    collapse = "|"
  ),
  # Add the special IL pattern
  "\\bIL\\b",      # standalone "IL"
  "IL-",           # "IL-" prefix (no word boundary needed after dash)
  sep = "|"
)

# Function to filter immune-related rows
filter_immune_rows <- function(df) {
  df %>%
    filter(
      if_any(
        .cols = c(
          annotation_stringdb,
          protein_name_uniprot,
          cc_function_uniprot,
          go_p_uniprot,
          go_f_uniprot,
          description_eggnog,
          preferred_name_eggnog,
          pfams_eggnog,
          interpro_description_ips,
          signature_description_ips
        ),
        .fns = ~ str_detect(.x, regex(immune_pattern, ignore_case = TRUE))
      )
    )
}

# ==== PER-MIRNA ====
per_mirna_ann_immune <- filter_immune_rows(per_mirna_ann)

# ==== ALL ====
all_ann_immune <- filter_immune_rows(all_ann)

