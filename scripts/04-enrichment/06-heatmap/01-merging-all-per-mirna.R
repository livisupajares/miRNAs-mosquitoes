# ~~~~~ MERGING ALL PER MIRNA ~~~~~
# This script is to see:
# - if some uniprot_id doesn't have any annotation or only one annotation
# - Add two variables `mirna_expression` and `common_mirna` to all per-mirna datasets
# - Merge all per-mirna datasets, including the ones with "down", including both species
# - Merge all "all" datasets, including both species.
# - Mantain sorting by `term_description` and by `false_discovery_rate`

# ===== LIBRARIES =====
library(dplyr)
library(tidylog, warn.conflicts = FALSE)

# ===== LOAD FILES =====
# Add merged results
source("scripts/04-enrichment/04-interproscan-annotations/02-merge-interpro-ann.R")

# Remove unused dfs
rm(aae_all_down_egg_uni)
rm(aae_all_down_merged)
rm(aae_all_egg_uni)
rm(aae_all_merged)
rm(aae_per_mirna_down_egg_uni)
rm(aae_per_mirna_down_merged)
rm(aae_per_mirna_egg_uni)
rm(aae_per_mirna_merged)
rm(aal_all_egg_uni)
rm(aal_all_merged)
rm(aal_per_mirna_egg_uni)
rm(aal_per_mirna_merged)
rm(interpro_important)
rm(merged)

# ==== REPLACE NON TRADITIONAL VALUES WITH NA =====
# Clean 'annotation_stringdb' across all data frames in merged_clean:
#   - "Uncharacterized protein." (case-insensitive, optional period/whitespace)
#   - Full-string VectorBase-like IDs: e.g., AAEL012979-PA, AALF001234-PB, AALF010145-PC., etc.

for (name in names(merged_clean)) {
  df <- merged_clean[[name]]
  
  if ("annotation_stringdb" %in% names(df)) {
    # Pattern 1: Uncharacterized protein (with optional period and spaces)
    is_uncharacterized <- grepl("^\\s*Uncharacterized protein\\.?\\s*$", 
                                df$annotation_stringdb, 
                                ignore.case = TRUE)
    
    # Pattern 2: VectorBase-style ID as the ENTIRE string
    # Format: [letters][digits]-[two uppercase letters] + optional period at end
    is_vectorbase_id <- grepl("^[A-Za-z]+[0-9]+-[A-Z]{2}\\.?\\s*$", 
                              df$annotation_stringdb)
    
    # Replace if either pattern matches
    df$annotation_stringdb[is_uncharacterized | is_vectorbase_id] <- NA_character_
  }
  
  merged_clean[[name]] <- df
}

