# ~~~~~~~~ MERGE ONLY ENRICHMENT DATAFRAMES
# This script is to merge only the enrichment dataframes (no annotations) for both
# `all` and `per_mirna` datasets, adding a `common_mirna` column to indicate common miRNAs.
# Add `mirna_expression` column where applicable.

# ===== LIBRARIES =====
library(dplyr)
library(tidylog, warn.conflicts = FALSE)

# ===== LOAD DATAFRAMES =====
aae_all_down <- read.csv("results/02-enrichment/02-exports-google-sheets/aae-all-down-stringdb-export.csv")
aae_all <- read.csv("results/02-enrichment/02-exports-google-sheets/aae-all-stringdb-export.csv")
aae_per_mirna_down <- read.csv("results/02-enrichment/02-exports-google-sheets/aae-per-mirna-down-stringdb-export.csv")
aae_per_mirna <- read.csv("results/02-enrichment/02-exports-google-sheets/aae-per-mirna-stringdb-export.csv")
aal_all <- read.csv("results/02-enrichment/02-exports-google-sheets/aal-all-stringdb-export.csv")
aal_per_mirna <- read.csv("results/02-enrichment/02-exports-google-sheets/aal-per-mirna-stringdb-export.csv")

# ==== ADD dataframes into a list =====
enrichment_only <- list(
  "aae_all_down" = aae_all_down,
  "aae_all" = aae_all,
  "aae_per_mirna" = aae_per_mirna,
  "aae_per_mirna_down" = aae_per_mirna_down,
  "aal_all" = aal_all,
  "aal_per_mirna" = aal_per_mirna
)

# ==== ADD mirna_expression COLUMN ====
for (name in names(enrichment_only)) {
  df <- enrichment_only[[name]]
  if (grepl("_down$", name)) {
    df$mirna_expression <- "down-regulated"
  } else if (grepl("^(aae|aal)_(per_mirna|all)$", name)) {
    df$mirna_expression <- "up-regulated"
  } else {
    df$mirna_expression <- NA_character_ # or skip if you prefer
  }
  enrichment_only[[name]] <- df
}

# ==== ADD common_mirna COLUMN ====
# Only for per_mirna data frames

# Define the special miRNAs in Aal that are "common"
common_aal_mirnas <- c("aal-mir-276-5p", "aal-mir-2945-3p", "aal-mir-2945b-3p")

for (name in names(enrichment_only)) {
  # Only process data frames with "per_mirna" in the name
  if (!grepl("per_mirna", name)) {
    next
  }

  df <- enrichment_only[[name]]

  # Ensure the 'mirna' column exists
  if (!("mirna" %in% names(df))) {
    warning("Data frame '", name, "' has no 'mirna' column; skipping common_mirna assignment.")
    next
  }

  # Initialize common_mirna as "no"
  df$common_mirna <- "no"

  # Special case: aae_per_mirna_down → all "yes"
  if (name == "aae_per_mirna_down") {
    df$common_mirna <- "yes"
  }
  # Special case: aal_per_mirna → specific miRNAs are "yes"
  else if (name == "aal_per_mirna") {
    df$common_mirna[df$mirna %in% common_aal_mirnas] <- "yes"
  }
  # For aae_per_mirna: remains "no" for all rows (as per your spec)

  enrichment_only[[name]] <- df
}

# ==== MOVE NEW COLUMNS =====
# Move common_mirna and mirna_expression after `mirna` inside the `per_mirna` dataframes
per_mirna_names <- c("aae_per_mirna", "aae_per_mirna_down", "aal_per_mirna")

enrichment_only[per_mirna_names] <- lapply(enrichment_only[per_mirna_names], function(df) {
  if (all(c("mirna", "mirna_expression", "common_mirna") %in% names(df))) {
    df %>% relocate(mirna_expression, common_mirna, .after = mirna)
  } else {
    df # return unchanged if columns missing
  }
})

# Move mirna_expression after `species` inside the `all` dataframes.
all_names <- c("aae_all", "aae_all_down", "aal_all")

enrichment_only[all_names] <- lapply(enrichment_only[all_names], function(df) {
  if ("species" %in% names(df) && "mirna_expression" %in% names(df)) {
    df %>% relocate(mirna_expression, .after = species)
  } else {
    df # return unchanged if required columns are missing
  }
})

# ==== MERGE ALL AND PER MIRNA DATAFRAMES =====
# Merge all `per_mirna` dataframes
enrichment_per_mirna <- bind_rows(
  enrichment_only$aae_per_mirna,
  enrichment_only$aae_per_mirna_down,
  enrichment_only$aal_per_mirna
)

# Merge all `all` dataframes
enrichment_all <- bind_rows(
  enrichment_only$aae_all,
  enrichment_only$aae_all_down,
  enrichment_only$aal_all
)

# ==== SAVE MERGED DATAFRAMES =====
write.csv(enrichment_per_mirna, file = "results/04-heatmap/final_enrichment_per_mirna.csv", row.names = FALSE)
write.csv(enrichment_all, file = "results/04-heatmap/final_enrichment_all.csv", row.names = FALSE)
