# ~~~~~ RNAHybrid post-processing aal-miR-34-5p ~~~~~ 
# This a script to parse RNAhybrid output into a readable dataframe,
# Then, it extracts and counts G:U mismatches in the seed and flanking regions and filters by:
# one G:U mismatch was permitted in the seed sequence
# maximum of three G:U mismatches were allowed in the flanking sequence
# Then it filters and sort by lowest energy values and lowest p value.

# ==== Load necessary libraries ====
library(dplyr)
library(stringr)