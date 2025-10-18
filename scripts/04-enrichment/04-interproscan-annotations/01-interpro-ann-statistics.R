# ~~~~~ INTERPROSCAN ANNOTATION STATISTICS ~~~~~
# This script is to see how many uniprot ids were not annotated with InterProScan
# and to add a column to isolate the uniprot_ids from the column that contains the fasta headers.

# ===== LOAD LIBRARIES =====
library(dplyr)
library(stringr)
library(tidylog, warn.conflicts = FALSE)
