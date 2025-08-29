# ~~~~~ FOLD ENRICHMENT CALCULATION ~~~~~ 
# This script is used to calculate the fold enrichment
# to see how much is a term enriched.
# To calculated we will create a function where :
# K = Observed gene count/total amount of protein coding genes in your input
# N = background_gene_count/total amount of protein coding genes in organism
# Finally we will divide K/N

# ==== IMPORT DATA =====
# We will import the intermediate results from the script
# 01-fuse-enrichment-results.R, before we took out the 
# unimportant terms
# Per miRNA
per_mirna <- read.csv("results/02-enrichment/03-enrichments-important-process/per-mirna-stringdb.csv")

# Venny
venny <- read.csv("results/02-enrichment/03-enrichments-important-process/venny-stringdb.csv") # no significant enrichment found

# All
all <- read.csv("results/02-enrichment/03-enrichments-important-process/all-stringdb.csv")

# ==== FOLD ENRICHMENT FUNCTION =====
# The formula is the same for both species,
# but the total amount of protein coding genes in organism differes between Aedes aegypti and
# Aedes albopictus.