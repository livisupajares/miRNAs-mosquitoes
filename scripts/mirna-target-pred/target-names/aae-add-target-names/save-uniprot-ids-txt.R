# ~~~~~ EXTRACT UNIPROT IDS FROM EACH MIRNA AND SAVE THEM TO TXT FILES ~~~~~
library(dplyr)
# ==== IMPORT DF ====
# Load the miRNA dataframes inside of a list to iterate over them
source("scripts/mirna-target-pred/target-names/aae-add-target-names/aae-add-target-names-consTarget-miranda.R")
