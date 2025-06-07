# ~~~~~ RNAHybrid post-processing aal-miR-34-5p ~~~~~ 
# This a script to parse RNAhybrid output into a readable dataframe,
# Then, it extracts and counts G:U mismatches in the seed and flanking regions and filters by:
# one G:U mismatch was permitted in the seed sequence
# maximum of three G:U mismatches were allowed in the flanking sequence
# Then it filters and sort by lowest energy values and lowest p value.

# ==== Load necessary libraries ====
library(dplyr)
library(stringr)

# ==== Load data ====
# Read RNAhybrid output
lines_aal <- readLines("results/rnahybrid/rnahybrid-aal-miR-34-5p.txt")

# ==== Vector for the dataframe ====
# Initialize vectors
targets <- c()
mfes <- c()
pvals <- c()
positions <- c()
GU_seed <- c()
GU_flank <- c()

# ==== Loop for parsing all block results ====
# Initiating our counter
i <- 1
while (i <= length(lines_aal)) {
  if (grepl("^target:", lines_aal[i])) {
    # Get target of each block
    target <- sub("^target: ", "", lines_aal[i])
    
    # Get mfe of each block
    mfe <- as.numeric(sub("mfe: ([-0-9.]+).*", "\\1", grep("^mfe:", lines_aal[(i+1):(i+10)], value = TRUE)))
    
    # Get p-value of each block
    pval <- as.numeric(sub("p-value: ([0-9.]+).*", "\\1", grep("^p-value:", lines_aal[(i+1):(i+10)], value = TRUE)))
    
    # Get position of each block position
    pos <- as.integer(sub("position\\s+([0-9]+).*", "\\1", grep("^position", lines_aal[(i+1):(i+10)], value = TRUE)))
    
    # Extract aligned base pairs (3 lines)
    align_start <- grep("^position", lines_aal[(i+1):(i+10)]) + i
    if (length(align_start) == 0) {
      i <- i + 1
      next
    }
    
    bp_target <- gsub("\\s+", "", lines_aal[align_start + 1])
    bp_middle <- gsub("\\s+", "", lines_aal[align_start + 2])
    bp_miRNA  <- gsub("\\s+", "", lines_aal[align_start + 3])
    
    # Alignment length check
    aln_len <- nchar(bp_middle)
    if (aln_len != nchar(bp_target) || aln_len != nchar(bp_miRNA)) {
      i <- i + 1
      next
    }
    
    # Count G:U wobbles
    gu_seed <- 0
    gu_flank <- 0
    for (j in 1:aln_len) {
      nt_t <- substr(bp_target, j, j)
      nt_m <- substr(bp_miRNA, j, j)
      
      # Complement G:U mismatch
      is_GU <- (nt_t == "G" & nt_m == "U") | (nt_t == "U" & nt_m == "G")
      
      # Consider positions 2-8 of miRNA as seed
      if (j >= 2 && j <= 8) {
        gu_seed <- gu_seed + is_GU
      } else {
        gu_flank <- gu_flank + is_GU
      }
    }
    
    # Save result
    targets <- c(targets, target)
    mfes <- c(mfes, mfe)
    pvals <- c(pvals, pval)
    positions <- c(positions, pos)
    GU_seed <- c(GU_seed, gu_seed)
    GU_flank <- c(GU_flank, gu_flank)
    
    i <- align_start + 3  # Skip to next block
  } else {
    i <- i + 1
  }
}

# ==== Save all results into a dataframe ====
# Create dataframe
df <- data.frame(
  target_id = targets,
  mfe = mfes,
  p_value = pvals,
  position = positions,
  GU_seed = GU_seed,
  GU_flank = GU_flank
)

# Filter: seed G:U <= 1, flank G:U <= 3
df_filtered <- df %>%
  filter(GU_seed <= 1, GU_flank <= 3) %>%
  arrange(p_value, mfe)

# Delete "-RX" part and delete duplicates
df_filtered$target_id <- sub("-R.*", "", df_filtered$target_id)

# Remove duplicated target_ids
df_unique <- df_filtered %>%
  distinct(target_id, .keep_all = TRUE)

# TODO: use biomaRt to look the name of the targets

# ==== Save Dataframe as csv ====
write.csv(df_unique, "results/rnahybrid/rnahybrid-aal-miR-34-5p-cleaned.csv", row.names = FALSE)