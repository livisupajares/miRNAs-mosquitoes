# ~~~~~~ FOLD ENRICHMENT ~~~~~
# This script is made to create a dispersion graph of the fold enrichment (SHINYGO & STRINGDB) of Aedes aegypti up-regulated miRNAs with common targets calculated by VENNY.

# Source utils functions and import libraries
source("scripts/functions.R")
library(ggplot2)
library(ggfittext) # Package to adjust text into ggplot2 plots

# ==== Load enrichment results ====
# Import .csv files
aae_venny_shinygo <- read.csv("results/enrichment/aae/aae-venny_upregulated_shinygo.csv", header = TRUE)
aae_venny_stringdb <- read.csv("results/enrichment/aae/aae-venny_upregulated_stringdb.csv", header = TRUE)

