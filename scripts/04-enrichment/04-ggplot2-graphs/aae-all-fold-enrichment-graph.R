# ~~~~~~ FOLD ENRICHMENT ~~~~~
# This script is made to create a dispersion graph of the fold enrichment (STRINGDB) of ALL Aedes aegypti and Aedes albopictus up-regulated miRNAs with targets.

# Source utils functions and import libraries
library(ggplot2)
library(dplyr)
library(stringr)

# ==== Load enrichment results ====
## Import .csv files
# All before filtering
per_mirna <- read.csv("results/02-enrichment/03-enrichments-important-process/per-mirna-stringdb.csv")
all <- read.csv("results/02-enrichment/03-enrichments-important-process/all-stringdb.csv")

# ==== Add -LogFDR column ======
per_mirna <- per_mirna |> mutate("-log(fdr)" = -log(false_discovery_rate))

all <- all |> mutate("-log(fdr)" = -log(false_discovery_rate))

# TODO: make the term description 50 characters max
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

# ==== Make Lolipop graphs ====
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
    # Filter first by species and dataset
    filtered_data <- dataframe |>
      filter(species == species_name, dataset == dataset_name) |>
      head(20) # Take up to top 20 after filtering

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

  # Create the lollipop plot
  p <- ggplot(
    data = filtered_data,
    aes(
      x = .data[[x_variable]],
      y = reorder(term_description, .data[[x_variable]]),
      color = false_discovery_rate,
      size = observed_gene_count
    )
  ) +
    # Add segments from x=0 to the points (lollipop sticks) - with same color mapping
    geom_segment(
      aes(
        x = 0, xend = .data[[x_variable]],
        y = reorder(term_description, .data[[x_variable]]),
        yend = reorder(term_description, .data[[x_variable]])
      ),
      linewidth = 0.5
    ) +
    # Add the points (lollipop heads)
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
    ) +
    # Add vertical line at x=0 for reference
    geom_vline(xintercept = 0, linetype = "dashed", alpha = 0.5)

  # Add vertical grid lines based on x_variable type
  if (x_variable == "signal") {
    x_range <- range(filtered_data[[x_variable]], na.rm = TRUE)
    x_seq <- seq(0, ceiling(x_range[2]), by = 0.25)
    p <- p + geom_vline(xintercept = x_seq, linetype = "dashed", alpha = 0.5, linewidth = 0.5)
  } else if (x_variable == "-log(fdr)") {
    # For -log(fdr): add lines every 10 units
    x_range <- range(filtered_data[[x_variable]], na.rm = TRUE)
    x_seq <- seq(0, ceiling(x_range[2] / 10) * 10, by = 10)
    p <- p + geom_vline(xintercept = x_seq, linetype = "dashed", alpha = 0.5, linewidth = 0.5)
  }

  # Return the plot
  return(p)
}

# ======== CREATE PLOTS ========
## Aedes aegypti
# See how many distinct datasets are there for Aedes aegypti only
all_aegypti <- all |>
  filter(species == "Aedes aegypti") |>
  distinct(dataset)
print(all_aegypti)

# All, Aedes aegypti, GO Biological Process, by signal
create_enrichment_plot(
  species_name = "Aedes aegypti",
  dataframe = all,
  dataset_name = "GO Biological Process",
  x_variable = "signal"
)
# All, Aedes aegypti, GO Biological Process, by -logFDR
create_enrichment_plot(
  species_name = "Aedes aegypti",
  dataframe = all,
  dataset_name = "GO Biological Process",
  x_variable = "-log(fdr)"
)

# All, Aedes aegypti, GO Cellular Component, by signal
create_enrichment_plot(
  species_name = "Aedes aegypti",
  dataframe = all,
  dataset_name = "GO Cellular Component",
  x_variable = "signal"
)

# All, Aedes aegypti, GO Cellular Component, by -logFDR
create_enrichment_plot(
  species_name = "Aedes aegypti",
  dataframe = all,
  dataset_name = "GO Cellular Component",
  x_variable = "-log(fdr)"
)

# All, Aedes aegypti, GO Molecular Function, by signal
create_enrichment_plot(
  species_name = "Aedes aegypti",
  dataframe = all,
  dataset_name = "GO Molecular Function",
  x_variable = "signal"
)

# All, Aedes aegypti, GO Molecular Function, by -logFDR
create_enrichment_plot(
  species_name = "Aedes aegypti",
  dataframe = all,
  dataset_name = "GO Molecular Function",
  x_variable = "-log(fdr)"
)

# All, Aedes aegypti, by signal, other
create_enrichment_plot(
  species_name = "Aedes aegypti",
  dataframe = all,
  x_variable = "signal",
  category_of_interest = "other"
)

# All, Aedes aegypti, by -log(fdr), other
create_enrichment_plot(
  species_name = "Aedes aegypti",
  dataframe = all,
  x_variable = "-log(fdr)",
  category_of_interest = "other"
)

## Aedes albopictus
# See how many distinct datasets are there for Aedes albopictus only
all_albopictus <- all |>
  filter(species == "Aedes albopictus") |>
  distinct(dataset)
print(all_albopictus)

# All, Aedes albopictus, Local Network Cluster String, by signal
create_enrichment_plot(
  species_name = "Aedes albopictus",
  dataframe = all,
  dataset_name = "Local Network Cluster String",
  x_variable = "signal"
)

# All, Aedes albopictus, Local Network Cluster String, by -logFDR
create_enrichment_plot(
  species_name = "Aedes albopictus",
  dataframe = all,
  dataset_name = "Local Network Cluster String",
  x_variable = "-log(fdr)"
)

# All, Aedes albopictus, Subcellular Location, by signal
create_enrichment_plot(
  species_name = "Aedes albopictus",
  dataframe = all,
  dataset_name = "Subcellular Location",
  x_variable = "signal"
)

# All, Aedes albopictus, Subcellular Location, by -logFDR
create_enrichment_plot(
  species_name = "Aedes albopictus",
  dataframe = all,
  dataset_name = "Subcellular Location",
  x_variable = "-log(fdr)"
)
