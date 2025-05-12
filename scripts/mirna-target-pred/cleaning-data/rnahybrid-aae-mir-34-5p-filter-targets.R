# ~~~~~ RNAHybrid post-processing aae-miR-34-5p ~~~~~ 
# This script to parse RNAhybrid output into a readable dataframe,
# It also used to extract and count G:U mismatches in the seed and flanking regions and filter by:
# one G:U mismatch was permitted in the seed sequence
# maximum of three G:U mismatches were allowed in the flanking sequence
# Then it filters and sort by lowest energy values and lowest p value.
