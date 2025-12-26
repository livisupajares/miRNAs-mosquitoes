# ~~~~~~ FOLD ENRICHMENT ~~~~~
# This script is made to create a dispersion graph of the fold enrichment (STRINGDB) of ALL Aedes aegypti and Aedes albopictus up-regulated and common miRNAs with targets.

# Source utils functions and import libraries
# library(ggplot2)
library(tidyplots)
library(dplyr)
library(stringr)

# ==== Load enrichment results ====
## Import .csv files
# All before filtering
all <- read.csv("results/02-enrichment/07-tidying-results/03-final-enrichment/final_enrichment_all.csv")
per_mirna <- read.csv("results/02-enrichment/07-tidying-results/03-final-enrichment/final_enrichment_per_mirna.csv")

# ==== Add -LogFDR column ======
per_mirna <- per_mirna |> mutate("neg_log_fdr" = -log(false_discovery_rate))

# -log(fdr)
all <- all |> mutate("neg_log_fdr" = -log(false_discovery_rate))

# ==== Arrange data frame by fold_enrichment/signal =====
## STRING DB
# All
all <- all |>
  group_by(species) |>
  group_by(category_of_interest) |>
  arrange(desc(signal), .by_group = TRUE)

# per-mirna
per_mirna <- per_mirna |>
  group_by(species) |>
  group_by(category_of_interest) |>
  arrange(desc(signal), .by_group = TRUE)

# ======== FILTER DATA ========
## Aedes aegypti
# See how many distinct datasets are there for Aedes aegypti only
all_aegypti <- all |>
  dplyr::filter(species == "Aedes aegypti") |>
  distinct(dataset)
print(all_aegypti)

# Mock up with tidyplots (I hope it makes the plot more compact)
all |>
  dplyr::filter(species == "Aedes aegypti", category_of_interest == "immune") |>
  tidyplot(x = neg_log_fdr, y = term_description, color = neg_log_fdr) |>
  add_data_points() |>
  add_mean_bar(width = 0.01) |>
  add_title("Enriched Terms from Aedes aegypti miRNA targets in all up-regulated and \ncommon down-regulated miRNAs (Category: immune)") |>
  rename_y_axis_labels(new_names = c("Regulation of receptor signaling pathway via JAK-STAT" = "Regulation of receptor \nsignaling pathway via \nJAK-STAT")) |>
  adjust_x_axis(title = "-log(FDR)") |>
  adjust_y_axis(title = "Term Description") |>
  adjust_legend_title("-log(FDR)") |>
  adjust_colors(colors_discrete_friendly)
# save_plot("/Users/skinofmyeden/Library/CloudStorage/GoogleDrive-livisu.pajares.r@upch.pe/My Drive/asistente-investigacion-upch-2025/miRNAs/FA5 Proposal/Objetivo 3 Enrichment/FINAL enrichment with annotations/lolipop-charts-enrichment/aae-immune-all.pdf")
# split_plot(by = mirna_expression)
