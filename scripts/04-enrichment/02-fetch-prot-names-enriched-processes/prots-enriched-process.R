# ~~~~~ PROTEINS OF ENRICHED PROCESES ~~~~~~
# This script splits the genes and pathway_genes into a list of protein ids for each enriched process.
# Then each list is saved into a dataframe with the process name and the list of protein ids.
# Then, the list of protein ids is matched to their names and/or descriptions with imported dataframes of mapped protein ids from ensembl metazoa or stringdb.

# ==== Load libraries ====
library(dplyr)
library(tidyr)

