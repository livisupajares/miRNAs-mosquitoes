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
aegypti_immune <- all |>
  dplyr::filter(species == "Aedes aegypti", category_of_interest == "immune")

## Aedes albopictus
# Fuse all and per-miRNA for Aedes albopictus visualization
albopictus_immune <- dplyr::bind_rows(
  all |>
    dplyr::filter(species == "Aedes albopictus", , category_of_interest == "immune"),
  per_mirna |>
    dplyr::filter(species == "Aedes albopictus", , category_of_interest == "immune")
)

# ======== PLOTS ========
# Aedes aegypti
aegypti_immune |>
  tidyplot(x = false_discovery_rate, y = term_description, color = neg_log_fdr) |>
  add_data_points() |>
  add_mean_bar(width = 0.01) |>
  add_title("Immune-related Enriched Terms from Aedes aegypti miRNA targets in all up-regulated and \ncommon down-regulated miRNAs (GO Biological Process)") |>
  rename_y_axis_labels(new_names = c("Regulation of receptor signaling pathway via JAK-STAT" = "Regulation of receptor \nsignaling pathway via \nJAK-STAT")) |>
  adjust_x_axis(title = "False discovery rate") |>
  adjust_y_axis(title = "Term Description") |>
  adjust_legend_title("-log(FDR)") |>
  adjust_colors(colors_diverging_blue2red) #|>
# save_plot("/Users/skinofmyeden/Documents/01-livs/20-work/upch-asistente-investigacion/miRNA-targets-fa5/figures-manuscript/aae-immune-all.pdf")
# split_plot(by = mirna_expression)

## Aedes albopictus
# First, compute appropriate breaks for the legend
min_fdr <- min(albopictus_immune$neg_log_fdr)
max_fdr <- max(albopictus_immune$neg_log_fdr)

# Due to the long range of -log(FDR), create breaks that cover the range nicely like in Aedes aegypti.
# Create breaks with 1 decimal place, covering the full range
legend_breaks <- seq(floor(min_fdr * 100) / 100, ceiling(max_fdr * 100) / 100, length.out = 4)

# Format labels with 1 decimal place
legend_labels <- sprintf("%.2f", legend_breaks)

albopictus_immune |>
  tidyplot(x = false_discovery_rate, y = term_description, color = neg_log_fdr) |>
  add_data_points() |>
  add_mean_bar(width = 0.01) |>
  add_title("Immune-related Enriched Terms from Aedes albopictus miRNA targets \nin up-regulated miRNAs (Local Network Cluster)") |>
  rename_y_axis_labels(new_names = c("DDE transposase retroviral integrase sub-family, and Reverse transcriptase/Diguanylate cyclase domain" = "DDE transposase retroviral \nintegrase sub-family, \nand Reverse transcriptase\n/Diguanylate cyclase domain", "Mixed, incl. Reverse transcriptase (RNA-dependent DNA polymerase), and Multifunctional anion exchangers" = "Reverse transcriptase \n(RNA-dependent DNA polymerase), \nand Multifunctional anion exchangers", "Mixed, incl. Attenuation phase, and Cyclosporin A binding" = "Attenuation phase, \nand Cyclosporin A binding", "Endonuclease-reverse transcriptase" = "Endonuclease-reverse \ntranscriptase")) |>
  adjust_x_axis(title = "False discovery rate") |>
  adjust_y_axis(title = "Term Description") |>
  adjust_legend_title("-log(FDR)") |>
  adjust_colors(colors_diverging_blue2red) |>
  adjust_colors(colors_diverging_blue2red,
    breaks = legend_breaks,
    labels = legend_labels
  )
# save_plot("/Users/skinofmyeden/Documents/01-livs/20-work/upch-asistente-investigacion/miRNA-targets-fa5/figures-manuscript/aal-immune-all-per-mirna.pdf")
# split_plot(by = mirna)
