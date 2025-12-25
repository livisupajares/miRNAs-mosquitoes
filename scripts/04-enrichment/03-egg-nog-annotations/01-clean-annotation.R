# ~~~~~ CLEAN ANNOTATION ~~~~~
# This script removes gene_primary from output of previous python script: 03-annotation-uniprot.py. It also rearranges some columns to be next to annotation column.

# ===== Add libraries =====
library(readr)
library(dplyr)
library(tidylog, warn.conflicts = FALSE)

# ===== Import data =====
full_expanded_all_down_stringdb_annotated <- read_csv("results/02-enrichment/04-enrich-full-anotation/output_uniprot_annotation/full-expanded-all-down-stringdb_annotated.csv")
full_expanded_all_stringdb_annotated <- read_csv("results/02-enrichment/04-enrich-full-anotation/output_uniprot_annotation/full-expanded-all-stringdb_annotated.csv")
full_expanded_per_mirna_down_stringdb_annotated <- read_csv("results/02-enrichment/04-enrich-full-anotation/output_uniprot_annotation/full-expanded-per-mirna-down-stringdb_annotated.csv")
full_expanded_per_mirna_stringdb_annotated <- read_csv("results/02-enrichment/04-enrich-full-anotation/output_uniprot_annotation/full-expanded-per-mirna-stringdb_annotated.csv")

# ===== Clean annotation =====
# Remove gene_primary
full_expanded_all_down_stringdb_annotated <- full_expanded_all_down_stringdb_annotated %>%
  dplyr::select(-gene_primary)
full_expanded_all_stringdb_annotated <- full_expanded_all_stringdb_annotated %>% dplyr::select(-gene_primary)
full_expanded_per_mirna_down_stringdb_annotated <- full_expanded_per_mirna_down_stringdb_annotated %>%
  dplyr::select(-gene_primary)
full_expanded_per_mirna_stringdb_annotated <- full_expanded_per_mirna_stringdb_annotated %>% dplyr::select(-gene_primary)

# Create function to arrange protein_name, cc_function, go_p and go_f to be next to annotation
move_annotation_cols <- function(df) {
  df %>% relocate(protein_name, cc_function, go_p, go_f, .after = annotation)
}

# Move columns
full_expanded_all_down_stringdb_annotated <- move_annotation_cols(full_expanded_all_down_stringdb_annotated)

full_expanded_all_stringdb_annotated <- move_annotation_cols(full_expanded_all_stringdb_annotated)

full_expanded_per_mirna_down_stringdb_annotated <- move_annotation_cols(full_expanded_per_mirna_down_stringdb_annotated)

full_expanded_per_mirna_stringdb_annotated <- move_annotation_cols(full_expanded_per_mirna_stringdb_annotated)

# Save data
write.csv(full_expanded_all_down_stringdb_annotated, file = "results/02-enrichment/04-enrich-full-anotation/output_uniprot_annotation/full-expanded-all-down-stringdb_annotated.csv", row.names = FALSE)

write.csv(full_expanded_all_stringdb_annotated, file = "results/02-enrichment/04-enrich-full-anotation/output_uniprot_annotation/full-expanded-all-stringdb_annotated.csv", row.names = FALSE)

write.csv(full_expanded_per_mirna_down_stringdb_annotated, file = "results/02-enrichment/04-enrich-full-anotation/output_uniprot_annotation/full-expanded-per-mirna-down-stringdb_annotated.csv", row.names = FALSE)

write.csv(full_expanded_per_mirna_stringdb_annotated, file = "results/02-enrichment/04-enrich-full-anotation/output_uniprot_annotation/full-expanded-per-mirna-stringdb_annotated.csv", row.names = FALSE)
