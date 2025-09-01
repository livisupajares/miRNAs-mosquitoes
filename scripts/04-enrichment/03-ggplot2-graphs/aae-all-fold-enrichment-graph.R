# ~~~~~~ FOLD ENRICHMENT ~~~~~
# This script is made to create a dispersion graph of the fold enrichment (STRINGDB) of ALL Aedes aegypti up-regulated miRNAs with targets.

# Source utils functions and import libraries
library(ggplot2)
library(dplyr)
library(glue)
library(ggrepel)
library(stringr)

# ==== Load enrichment results ====
## Import .csv files
# All before filtering
per_mirna <- read.csv("results/02-enrichment/03-enrichments-important-process/per-mirna-stringdb.csv")
all <- read.csv("results/02-enrichment/03-enrichments-important-process/all-stringdb.csv")

# ==== Shorten description =====
# truncate long descriptions to first 50 characters
## STRINGDB
# All after filtering
# filt_all_stringdb$short_description <- ifelse(nchar(filt_all_stringdb$term_description) > 50,
#   paste0(substr(filt_all_stringdb$term_description, 1, 47), "..."),
#   filt_all_stringdb$term_description
# )

# ==== Arrange data frame by fold_enrichment/signal =====
## STRING DB
# All
all <- all |>
  group_by(species) |>
  arrange(desc(signal), .by_group = TRUE)

# per-mirna
per_mirna <- per_mirna |>
  group_by(species) |>
  arrange(desc(signal), .by_group = TRUE)

# ==== Make dispersion graphs ====
## Stringdb
# This is a function to plot from highest to lowest signal (arranged above). It colors by FDR values and the dot size is correlated to nº of observed gene count in each term
# Arrange from highest to lowest signal
# It works for both mosquito species.
  
create_enrichment_plot <- function(species_name, dataframe, dataset_name, x_variable) {
  # inputs:
  # species_name = "Aedes aegypti" or "Aedes albopictus"
  # dataframe = "all" or "per_mirna",
  # dataset_name = "GO Biological Proces", "GO Cellular Component", "GO Molecular Function"; "Kegg", "Reactome", etc.
  # x_variable = "signal", -log(FDR)
  # 
  # Filter the data first
  filtered_data <- dataframe[1:20, ] |>
    filter(species == species_name, dataset == dataset_name)
  # Get the x variable column
  x_values <- filtered_data[[x_variable]]

  ggplot(data = filtered_data, 
         aes(
           x = .data[[x_variable]],
           y = reorder(term_description, .data[[x_variable]]),
           color = false_discovery_rate,
           size = observed_gene_count
         )) +
    geom_point() +
    
    # Gradient color scale for FDR
    scale_color_gradient(low = "red", high = "blue", name = "FDR") +
    
    # Simplify theme without dynamic y-axis label colors
    ggtitle(stringr::str_wrap(paste("Enriched Terms from", dataset_name, "of", species_name, "miRNA targets in all up-regulated miRNAs"))) +
    theme(
      axis.text.y = element_text(size = 10), # Smaller y-axis text
      axis.text.x = element_text(size = 10), # Smaller x-axis numbers
      plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
      legend.position = "right"
    ) +
    labs(
      x = x_variable,
      y = "Term Description",
      size = "Gene Count"
    )
}

# ======== CREATE PLOTS ========
# All, Aedes aegypti, GO Biological Process, by signal and FDR
create_enrichment_plot(species_name = "Aedes aegypti", 
              dataframe = all, 
              dataset_name = "GO Biological Process", 
              x_variable = "signal")
