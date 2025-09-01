# ~~~~~~ FOLD ENRICHMENT ~~~~~
# This script is made to create a dispersion graph of the fold enrichment (STRINGDB) of ALL Aedes aegypti and Aedes albopictus up-regulated miRNAs with targets.

# Source utils functions and import libraries
library(ggplot2)
library(dplyr)
library(ggrepel)
library(stringr)

# ==== Load enrichment results ====
## Import .csv files
# All before filtering
per_mirna <- read.csv("results/02-enrichment/03-enrichments-important-process/per-mirna-stringdb.csv")
all <- read.csv("results/02-enrichment/03-enrichments-important-process/all-stringdb.csv")

# ==== Add -LogFDR column ======
per_mirna <- per_mirna |> mutate("-log(fdr)" = -log(false_discovery_rate))

all <- all |> mutate("-log(fdr)" = -log(false_discovery_rate))
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
  
create_enrichment_plot <- function(species_name, dataframe, dataset_name = NULL, x_variable, category_of_interest = NULL) {
  # inputs:
  # species_name = "Aedes aegypti" or "Aedes albopictus"
  # dataframe = "all" or "per_mirna",
  # dataset_name = "GO Biological Proces", "GO Cellular Component", "GO Molecular Function"; "Kegg", "Reactome", etc.
  # x_variable = "signal", -log(FDR)
  # category_of_interest = optional string value from category_of_interest column (default = NULL)
  
  # Filter the data first
  if (is.null(category_of_interest)) {
    # Filter only by species and dataset (original behavior)
    filtered_data <- dataframe[1:20, ] |>
      filter(species == species_name, dataset == dataset_name)
    
    # Create title without category filter
    plot_title <- paste("Enriched Terms from", dataset_name, "of", species_name, "miRNA targets in all up-regulated miRNAs")
  } else {
    # Filter by species, dataset, AND category_of_interest
    filtered_data <- dataframe |>
      filter(species == species_name, category_of_interest == !!category_of_interest)
    
    # Create title with category filter
    plot_title <- paste("Enriched Terms from", species_name, "miRNA targets in all up-regulated miRNAs (Category:", category_of_interest, ")")
  }
  
  # Check if filtered_data has rows
  if (nrow(filtered_data) == 0) {
    stop("No data found for the specified filters")
  }
  
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
    ggtitle(stringr::str_wrap(plot_title)) +
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
# All, Aedes aegypti, GO Biological Process, by signal
create_enrichment_plot(species_name = "Aedes aegypti", 
              dataframe = all, 
              dataset_name = "GO Biological Process", 
              x_variable = "signal")
# All, Aedes aegypti, GO Biological Process, by -logFDR
create_enrichment_plot(species_name = "Aedes aegypti", 
                       dataframe = all, 
                       dataset_name = "GO Biological Process", 
                       x_variable = "-log(fdr)")

# All, Aedes aegypti, by signal, immune
create_enrichment_plot(species_name = "Aedes aegypti", 
                       dataframe = all, 
                       x_variable = "signal",
                       category_of_interest = "other")
 