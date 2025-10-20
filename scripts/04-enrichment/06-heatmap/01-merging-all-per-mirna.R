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

# ==== STATISTICS =====
# Determine which `uniprot_id` has no anotations (NAs in `annotation_stringdb`, `protein_name_uniprot`, `cc_function_uniprot`, `go_p_uniprot`, `go_f_uniprot`, `description_eggnog`, `preferred_name_eggnog`, `interpro_description_ips`, and `signature_description_ips`)

cat("=== UniProt IDs with ALL columns as NA ===\n")
for (name in names(merged_clean)) {
  df <- merged_clean[[name]]
  uniprot_na <- df %>%
    filter(is.na(annotation_stringdb) &
             is.na(protein_name_uniprot) &
             is.na(cc_function_uniprot) &
             is.na(go_p_uniprot) &
             is.na(go_f_uniprot) &
             is.na(description_eggnog) &
             is.na(preferred_name_eggnog) &
             is.na(interpro_description_ips) &
             is.na(signature_description_ips)) %>%
    pull(uniprot_id) %>%
    unique()
  cat(name, "\n")
  cat(sprintf("Count: %d\n", length(uniprot_na)))
  if (length(uniprot_na) > 0) {
    cat("UniProt IDs:\n")
    print(uniprot_na)
  } else {
    cat("No UniProt IDs found with all columns as NA.\n")
  }
  cat("\n")
}

# Determine which `uniprot_id` has only ONE anotation (data in `annotation_stringdb`, `protein_name_uniprot`, `cc_function_uniprot`, `go_p_uniprot`, `go_f_uniprot`, `description_eggnog`, `preferred_name_eggnog`, `interpro_description_ips`, and/or `signature_description_ips`, except in one of those annotation columns)

# Define the annotation columns of interest
annotation_cols <- c(
  "annotation_stringdb",
  "protein_name_uniprot",
  "cc_function_uniprot",
  "go_p_uniprot",
  "go_f_uniprot",
  "description_eggnog",
  "preferred_name_eggnog",
  "interpro_description_ips",
  "signature_description_ips"
)

# Initialize a list to store results
single_annotation_results <- list()

cat("=== UniProt IDs with EXACTLY ONE non-NA annotation ===\n")
for (name in names(merged_clean)) {
  df <- merged_clean[[name]]
  
  # Count non-NA values per row across annotation columns
  non_na_counts <- rowSums(!is.na(df[annotation_cols]), na.rm = TRUE)
  
  # Identify rows with exactly one non-NA annotation
  one_annot <- df[non_na_counts == 1, , drop = FALSE]
  
  if (nrow(one_annot) == 0) {
    cat(name, "\n")
    cat("Count: 0\n")
    cat("No UniProt IDs found with exactly one annotation.\n\n")
    single_annotation_results[[name]] <- data.frame()  # store empty df
    next
  }
  
  # Safely extract column name and value
  annotation_info <- t(sapply(1:nrow(one_annot), function(i) {
    row_vals <- one_annot[i, annotation_cols, drop = FALSE]
    idx <- which(!is.na(row_vals))
    if (length(idx) == 1) {
      col_name <- names(row_vals)[idx]
      value <- row_vals[[idx]]
      return(c(column = col_name, value = value))
    } else {
      return(c(column = NA_character_, value = NA_character_))
    }
  }))
  
  # Handle single-row edge case
  if (is.null(dim(annotation_info))) {
    annotation_info <- matrix(annotation_info, nrow = 1, dimnames = list(NULL, c("column", "value")))
  }
  
  result_df <- data.frame(
    uniprot_id = one_annot$uniprot_id,
    annotation_column = annotation_info[, "column"],
    annotation_value = annotation_info[, "value"],
    stringsAsFactors = FALSE,
    row.names = NULL
  )
  
  # Save to list
  single_annotation_results[[name]] <- result_df
  
  # Print summary (optional, can remove if you only want silent storage)
  cat(name, "\n")
  unique_count <- length(unique(result_df$uniprot_id))
  cat(sprintf("Count (unique UniProt IDs): %d\n", unique_count))
  cat("Details stored in single_annotation_results[['", name, "']]\n\n", sep = "")
}
