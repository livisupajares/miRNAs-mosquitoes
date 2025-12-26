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
  adjust_colors(colors_diverging_blue2red) |>
  save_plot("/Users/skinofmyeden/Documents/01-livs/20-work/upch-asistente-investigacion/miRNA-targets-fa5/figures-manuscript/aae-immune-all.pdf")
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
  adjust_colors(colors_diverging_blue2red,
    breaks = legend_breaks,
    labels = legend_labels
  ) |>
  save_plot("/Users/skinofmyeden/Documents/01-livs/20-work/upch-asistente-investigacion/miRNA-targets-fa5/figures-manuscript/aal-immune-all-per-mirna.pdf")
# split_plot(by = mirna)

###############################################
# DEBUGGING CODE - TO BE REMOVED LATER #
# ###############################################

albopictus_immune_sample <- as.data.frame(albopictus_immune |>
  dplyr::select(term_description, false_discovery_rate, neg_log_fdr))

aegypti_immune_sample <- as.data.frame(aegypti_immune |>
  dplyr::select(term_description, false_discovery_rate, neg_log_fdr))

# Debuggin 2. Minimal example:
library(tidyplots)

# Akin to Aedes aegypti

df1 <- data.frame(
  term_description = c("Term 1", "Term 2"),
  false_discovery_rate = c(0.0093, 0.0097),
  neg_log_fdr = c(4.677741, 4.635629) # Range: ~0.04
)

# Df1 range of -log(fdr) is very small: 0.042112 difference between max and min
# Range calculation
range(df1$neg_log_fdr) # Difference: 0.042112

df1 |>
  tidyplot(x = false_discovery_rate, y = term_description, color = neg_log_fdr) |>
  add_data_points() |>
  add_mean_bar(width = 0.01) |>
  adjust_colors(colors_diverging_blue2red)

# Legend shows decimals automatically (correct)

# Akin to Aedes albopictus

df2 <- data.frame(
  term_description = c("Term 1", "Term 2", "Term 3", "Term 4"),
  false_discovery_rate = c(0.00670, 0.00037, 0.00600, 0.00480),
  neg_log_fdr = c(5.005648, 7.902008, 5.115996, 5.339139) # Range: ~2.9
)

# Df2 range of -log(fdr) is bigger than df1: 2.89636 difference between max and min
range(df2$neg_log_fdr) # Difference: 2.89636

df2 |>
  tidyplot(x = false_discovery_rate, y = term_description, color = neg_log_fdr) |>
  add_data_points() |>
  add_mean_bar(width = 0.01) |>
  adjust_legend_title("-log(FDR)") |>
  adjust_colors(colors_diverging_blue2red)

# -------------

# Workaround of explicitely adding breaks and labels in df2 does show the decimals but it won't show 4 breaks just 2:

min_fdr <- min(df2$neg_log_fdr)
max_fdr <- max(df2$neg_log_fdr)

# Create 4 breaks
legend_breaks <- seq(floor(min_fdr * 100) / 100, ceiling(max_fdr * 100) / 100, length.out = 4)

print(legend_breaks) # 5.00 5.97 6.94 7.91

# Format labels with 2 decimal place based on legend_breaks
legend_labels <- sprintf("%.2f", legend_breaks)

df2 |>
  tidyplot(x = false_discovery_rate, y = term_description, color = neg_log_fdr) |>
  add_data_points() |>
  add_mean_bar(width = 0.01) |>
  adjust_legend_title("-log(FDR)") |>
  adjust_colors(colors_diverging_blue2red,
    breaks = legend_breaks,
    labels = legend_labels,
    limits = c(min_fdr, max_fdr)
  )
