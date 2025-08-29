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

# Constants
# total amount of protein coding genes in your input
## TODO: Calculated from fasta file in per-mirna, all and venny using seqkit in the terminal
# total amount of protein coding genes in organism
# TODO: Write seqkit command and results here for reference
## From the stringdb website, look up for Aedes aegypti and Aedes albopictus in the "Organisms" option from the sidebar. 
fold_enrichment_calc <- function(df, n_prot_coding_genes_input) {
  if (df$species == "Aedes aegypti") {
    n_protein_genes_org <- 15757
    fold_enrichment <- (df$observed_gene_count/n_prot_coding_genes_input)/(df$background_gene_count/n_protein_genes_org)
    print(fold_enrichment)
  } 
  else {
    n_protein_genes_org <- 16616
    fold_enrichment <- (df$observed_gene_count/n_prot_coding_genes_input)/(df$background_gene_count/n_protein_genes_org)
    print(fold_enrichment)
  }
}