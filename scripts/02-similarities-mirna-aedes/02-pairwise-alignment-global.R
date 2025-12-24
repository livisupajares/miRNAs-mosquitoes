# ~~~~ Pairwise alignment global of miRNAs (match by sequence) ~~~~
# This script has the purpose to align the mature sequences of miRNAs infected with DENV-2 from up and down-regulated Aedes aegypti and up-regulated Aedes albopictus. This script also creates publication ready figures of the top 3 alignments.

# ==== Load libraries ====
# Instala Biostrings si no lo tienes
# if (!requireNamespace("BiocManager", quietly = TRUE)) {
#   install.packages("BiocManager")
# }
# BiocManager::install("Biostrings")
# BiocManager::install("pwalign")

# Load libraries
library(Biostrings)
library(pwalign)
library(ggmsa)
library(ggplot2)

# ==== Load fasta files into RNAStringSet objects ====
# up-regulated Aedes albopictus
albopictus <- readRNAStringSet("sequences/01-isolating-mature-sequences/aal_mat_denv_up.fasta")

# up and down-regulated Aedes aegypti
aegypti <- readRNAStringSet("sequences/01-isolating-mature-sequences/aae_mat_denv_up_down.fasta")

# ==== Convert fasta to list to prepare the pairwise alignment ====
# Obtain names and IDs
names_albo <- names(albopictus)
names_aegypti <- names(aegypti)

# Create an empty list and an empty matrix (with aal miRNAs in rows and aae miRNAs in the columns) to save alignments and score alignments
alignment_list <- list() # The alignments will be saved here
score_matrix <- matrix(NA,
  nrow = length(albopictus), ncol = length(aegypti),
  dimnames = list(names_albo, names_aegypti)
)

# ==== Local Paiwise Alignment ====
# Align each combination and save the score and alignment
# Be patient, it's going to take some time. Time for our coffee break ☕
for (i in seq_along(albopictus)) {
  for (j in seq_along(aegypti)) {
    alignment <- pwalign::pairwiseAlignment(
      pattern = albopictus[[i]],
      subject = aegypti[[j]],
      type = "global"
    )
    score_matrix[i, j] <- score(alignment)
    alignment_list[[paste(names_albo[i], names_aegypti[j], sep = "_vs_")]] <- alignment
  }
}

# ==== Best alignment ====
# Find the best matches and show aligned sequences
# The best scores are positive scores, so we will look for the maximum score in each row of the score matrix

# collect all best matches with their scores
best_matches <- data.frame(
  albo_name = character(),
  aegypti_name = character(),
  score = numeric(),
  key = character(),
  stringsAsFactors = FALSE
)

for (i in seq_along(albopictus)) {
  # Find best matches
  best_j <- which.max(score_matrix[i, ])
  best_name <- names_aegypti[best_j]
  best_score <- score_matrix[i, best_j]
  key <- paste(names_albo[i], best_name, sep = "_vs_")

  # Add to data frame
  best_matches <- rbind(best_matches, data.frame(
    albo_name = names_albo[i],
    aegypti_name = best_name,
    score = best_score,
    key = key,
    stringsAsFactors = FALSE
  ))
}

# Sort by score in descending order (highest scores first)
best_matches <- best_matches[order(best_matches$score, decreasing = TRUE), ]
best_matches <- best_matches[1:min(5, nrow(best_matches)), ] # Show only top 5

# Print results sorted by score
cat(" Best alignments (sorted by highest scores):\n\n")
for (i in 1:nrow(best_matches)) {
  row <- best_matches[i, ]
  best_alignment <- alignment_list[[row$key]]

  # Print results with score
  cat(paste0("▶ Rank ", i, " - Score: ", row$score, "\n"))
  cat(paste0("   ", row$albo_name, " vs ", row$aegypti_name, "\n"))
  print(best_alignment)
  cat("\n")
}

# ==== Create publication ready figures of the top 3 alignments ====
for (i in 1:3) {
  row <- best_matches[i, ]
  best_alignment <- alignment_list[[row$key]]

  # Use alignedPattern() and alignedSubject() to get sequences WITH gaps
  pattern_seq <- as.character(alignedPattern(best_alignment))
  subject_seq <- as.character(alignedSubject(best_alignment))

  # Check the sequences have gaps
  cat(paste0("\n=== Rank ", i, " ===\n"))
  cat("Pattern: ", pattern_seq, "\n")
  cat("Subject: ", subject_seq, "\n")

  # Create RNA StringSet with proper names
  aligned_seqs <- RNAStringSet(c(pattern_seq, subject_seq))
  names(aligned_seqs) <- c(row$albo_name, row$aegypti_name)

  # Write to temporary fasta file
  temp_file <- paste0("temp_alignment_rank", i, ".fasta")
  writeXStringSet(aligned_seqs, filepath = temp_file)

  # Create the plot
  p <- ggmsa(temp_file,
    start = 1,
    end = nchar(pattern_seq),
    color = "Chemistry_NT",
    char_width = 0.5,
    seq_name = TRUE
  ) +
    ggtitle(paste0("Rank ", i, ": ", row$albo_name, " vs ", row$aegypti_name),
      subtitle = paste0("Alignment Score: ", round(row$score, 5))
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(size = 12),
      axis.text.y = element_text(size = 10),
      axis.text.x = element_text(size = 9)
    ) +
    scale_size_manual(values = 3)

  print(p)

  # Save high-resolution figure
  # Note these ggsave paths are hard-coded because I didn't want to make this repo too big in size and then cause problems down the line.
  ggsave(paste0("/Users/skinofmyeden/Documents/01-livs/20-work/upch-asistente-investigacion/miRNA-targets-fa5/figures-manuscript/pairwise_alignment_rank_", i, ".png"),
    p,
    width = 12, height = 3, dpi = 300, bg = "white"
  )

  ggsave(paste0("/Users/skinofmyeden/Documents/01-livs/20-work/upch-asistente-investigacion/miRNA-targets-fa5/figures-manuscript/pairwise_alignment_rank_", i, ".pdf"),
    p,
    width = 12, height = 3
  )

  # Clean up temp file
  file.remove(temp_file)
}
