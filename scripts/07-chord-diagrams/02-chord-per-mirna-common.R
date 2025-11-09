# ~~~~ CHORD DIAGRAMS FOR PER-MIRNA COMMON TARGETS ~~~~
# This script will create a chord diagram to visualize common targets of miRNAs in Aedes aegypti (down-regulated) and Aedes albopictus (up-regulated).

# ===== Libraries =====
library(circlize)
library(tibble)
library(dplyr)
library(tidyr)
library(tidylog, warn.conflicts = FALSE)

# ===== Import data =====
source("scripts/07-chord-diagrams/01-filter-subgroups.R")
rm(all_new)
rm(per_mirna_new)
rm(aae_all)
rm(aae_per_mirna)
rm(aal_per_mirna)
rm(aae_common_all)
rm(aal_all)

# ===== PREPARE DATA FOR CHORD DIAGRAMS =====
# Create a presence/absence matrix of everything
## Common per-miRNA
pa_full_common_per_mirna <- common_per_mirna %>%
  filter(!is.na(mirna), mirna != "") %>%
  mutate(presence = 1) %>%
  pivot_wider(
    names_from = mirna,
    values_from = presence,
    values_fill = list(presence = 0)
  )

# Prepare long format edge list for chord diagram
edge_list <- pa_full_common_per_mirna %>%
  # Keep only relevant columns
  select(
    protein_name,
    term_description,
    dataset, # e.g., "GO Biological Process"
    category_of_interest, # e.g., "immune"
    mirna_expression, # e.g., "up", "down"
    species, # Aedes aegypti or Aedes albopictus
    starts_with("aa") # your miRNA columns
  ) %>%
  # Reshape to long format: one row per miRNA-target pair
  pivot_longer(
    cols = starts_with("aa"),
    names_to = "miRNA",
    values_to = "presence"
  ) %>%
  filter(presence == 1) %>% # Only keep actual interactions
  mutate(
    # Optional: create unique protein IDs if needed later
    protein_id = paste0(protein_name, "_", term_description),
    # Clean up for plotting
    protein_name = as.character(protein_name),
    miRNA = as.character(miRNA)
  )

# Clean and enforce character type
edge_list$miRNA <- trimws(as.character(edge_list$miRNA))
edge_list$protein_name <- trimws(as.character(edge_list$protein_name))

# ==== Define circular layout =====
# Let's define two sectors:
# 1) Sector 1: miRNAs (bottom half)
# 2) Sector 2: Targets (top half)

# Get unique miRNAs and proteins
unique_miRNAs <- unique(edge_list$miRNA)
unique_proteins <- unique(edge_list$protein_name) # or protein_id if you use it

# Create sector names
sector_names <- c(unique_miRNAs, unique_proteins)
sector_names <- trimws(as.character(sector_names))

# Check for DUPLICATE sector names
duplicated_sectors <- sector_names[duplicated(sector_names)]
if (length(duplicated_sectors) > 0) {
  stop(
    "❌ Duplicated sector names found! This breaks circlize.\nDuplicated: ",
    paste(duplicated_sectors, collapse = ", ")
  )
}

# ==== Assign colors and annotations =====
# Color miRNAs by expression
# Map miRNA expression to color
mirna_color_map <- edge_list %>%
  distinct(miRNA, mirna_expression) %>%
  mutate(
    color = case_when(
      mirna_expression == "up-regulated" ~ "red",
      mirna_expression == "down-regulated" ~ "blue",
      TRUE ~ "gray"
    )
  ) %>%
  select(miRNA, color) %>% # Remove the mirna_expression column or deframe won't work (requires 2 columns not 3)
  deframe()

# Color targets by category/dataset
protein_color_map <- edge_list %>%
  distinct(protein_name, category_of_interest, dataset) %>%
  mutate(
    color = case_when(
      # category_of_interest == "immune" ~ "orange",
      # dataset == "GO Biological Process" ~ "lightgreen",
      dataset == "GO Cellular Component" ~ "lightblue",
      dataset == "GO Molecular Function" ~ "purple",
      dataset == "Local Network Cluster String" ~ "lightgreen",
      dataset == "Subcellular Location" ~ "pink",
      dataset == "Reactome" ~ "yellow",
      dataset == "SMART" ~ "brown",
      dataset == "InterPro" ~ "cyan",
      TRUE ~ "gray"
    ),
    # Add a marker for immune (e.g., square)
    # marker = ifelse(category_of_interest == "immune", "square", "circle")
  ) %>%
  select(protein_name, color) %>% # Remove other columns for deframe
  deframe()

# Create a legend for sectors
# Define sector annotations
sector_annotation <- data.frame(
  sector = c(rep("miRNA", length(unique_miRNAs)), rep("protein", length(unique_proteins))),
  name = sector_names,
  stringsAsFactors = FALSE
)

# ==== Create chord diagram (with annotations) =====
# circos.clear()

# Initialize plot
circos.initialize(factors = sector_names, xlim = c(0, 1))

# SINGLE TRACK: background + labels (ensures full sector initialization)
circos.track(
  ylim = c(0, 1),
  track.height = 0.2, # taller to fit both color and label
  panel.fun = function(x, y) {
    sector.name <- get.cell.meta.data("sector.index")

    # --- Background color ---
    if (sector.name %in% names(mirna_color_map)) {
      bg_col <- mirna_color_map[sector.name]
    } else if (sector.name %in% names(protein_color_map)) {
      bg_col <- protein_color_map[sector.name]
    } else {
      bg_col <- "white"
    }
    circos.rect(0, 0, 1, 1, col = bg_col, border = NA)

    # --- Label ---
    circos.text(
      x = 0.5, y = 0.3, # slightly lower to avoid overlap
      labels = sector.name,
      facing = "clockwise",
      niceFacing = TRUE,
      cex = 0.6
    )
  },
  bg.border = NA
)

# Draw links
for (i in 1:nrow(edge_list)) {
  miRNA_name <- edge_list$miRNA[i]
  protein_name <- edge_list$protein_name[i]

  # Ensure both are in sector_names (optional, but safe)
  if (!(miRNA_name %in% sector_names) || !(protein_name %in% sector_names)) {
    warning("Skipping link: miRNA='", miRNA_name, "' or protein='", protein_name, "' not in sector_names")
    next
  }

  link_color <- mirna_color_map[miRNA_name]

  circos.link(
    sector.index1 = miRNA_name, # ← USE NAME, not index
    point1 = 0.5,
    sector.index2 = protein_name, # ← USE NAME, not index
    point2 = 0.5,
    col = link_color,
    border = NA,
    lwd = 0.5
  )
}
