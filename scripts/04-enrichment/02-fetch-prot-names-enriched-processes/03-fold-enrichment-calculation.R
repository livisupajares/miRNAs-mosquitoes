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
# See which miRNAs are present in the dataframe
print(unique(per_mirna$mirna))

# Venny
# # no significant enrichment found, therefore we don't load it into memory
# venny <- read.csv("results/02-enrichment/03-enrichments-important-process/venny-stringdb.csv")

# All
all <- read.csv("results/02-enrichment/03-enrichments-important-process/all-stringdb.csv")

# ==== FOLD ENRICHMENT FUNCTION =====
# The formula is the same for both species,
# but the total amount of protein coding genes in organism differes between
# Aedes aegypti and Aedes albopictus.

# Constants
# total amount of protein coding genes in your input
## Calculated from fasta file in per-mirna, all and venny using seqkit in the
## terminal
## Command:
# seqkit stats *.fasta | csvtk pretty -t
# For aae-all = 894 protein coding genes
# For aal-all = 864 protein coding genes
# For aae-mir-34-5p = 778 protein coding genes
# For aae-mir-5119-5p = 127 protein coding genes
# For aal-mir-87 = 95 protein coding genes
# aal-mir-193-5p = 76 protein coding genes
# aal-mir-276-5p = 76 protein coding genes
# aal-mir-622 = 136 protein coding genes
# aal-mir-970-3p = 40 protein coding genes
# aal-mir-1951 = 32 protein coding genes
# aal-mir-4728-5p = 198 protein coding genes

# total amount of protein coding genes in organism
## From the stringdb website, look up for Aedes aegypti and Aedes albopictus in
## the "Organisms" option from the sidebar.
## TODO: Add condition to check if df contains "all" or "per_mirna" in the name,
## and add the correct amount of protein coding genes
## TODO: For each species inside per_mirna, add a condition to check which miRNA
## is inside the mirna variable, and add the correct amount of protein coding
## genes.
fold_enrichment_calc <- function(df, n_prot_coding_genes_input) {
  if (df$species == "Aedes aegypti") {
    n_protein_genes_org <- 15757
    fold_enrichment <- (df$observed_gene_count / n_prot_coding_genes_input) / (df$background_gene_count / n_protein_genes_org)
    print(fold_enrichment)
  } else {
    n_protein_genes_org <- 16616
    fold_enrichment <- (df$observed_gene_count / n_prot_coding_genes_input) / (df$background_gene_count / n_protein_genes_org)
    print(fold_enrichment)
  }
}

# ==== TEST & DEBUG FUNCTION ====
# Subset a part of the dataframe, in this case, only one row
test_all_row <- all[1, ]
# TODO: Add total amount of protein coding genes in your input as a second argument in function
result_all_row <- fold_enrichment_calc(test_all_row)
