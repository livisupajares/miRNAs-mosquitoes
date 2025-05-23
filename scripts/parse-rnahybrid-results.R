# ~~~~ PARSE RNAHYBRID BLOCKS ~~~~~ 
# This script is a test function to parse target name, mfe, pval, pos and G:U wobbles in a single block (sample result) of a sample result hit

# Test block
test_lines <- c(
  "target: AAEL000037-RA",
  "length: 93",
  "miRNA : aae-miR-34-5p",
  "length: 22",
  "",
  "mfe: -23.9 kcal/mol",
  "p-value: 0.021568",
  "",
  "position  25",
  "target 5' G  U     CG      CUAAUAA       A 3'",
  "           GA CUAGU  AAUCAC       GCUGCUA    ",
  "           UU GGUCG  UUGGUG       UGACGGU    ",
  "miRNA  3' G        A                       5'"
)

parse_rnahybrid_block <- function(block_lines) {
  # Extract values from block
  target <- sub("^target: ", "", block_lines[1])
  mfe <- as.numeric(sub("mfe: ([-0-9.]+).*", "\\1", grep("^mfe:", block_lines, value = TRUE)))
  pval <- as.numeric(sub("p-value: ([0-9.]+).*", "\\1", grep("^p-value:", block_lines, value = TRUE)))
  pos <- as.integer(sub("position\\s+([0-9]+).*", "\\1", grep("^position", block_lines, value = TRUE)))
  print(pos)
  
  # Alignment lines
  align_start <- grep("^position", block_lines)
  if (length(align_start) == 0 || align_start + 3 > length(block_lines))   {
    stop("Invalid alignment block structure")
  }
  print(align_start)
  
  bp_target <- gsub("\\s+", "", block_lines[align_start + 1])
  bp_middle <- gsub("\\s+", "", block_lines[align_start + 2])
  bp_miRNA  <- gsub("\\s+", "", block_lines[align_start + 3])
  
  # aln_len which is nº of characters in bp_middle
  aln_len <- nchar(bp_middle)
  
  # Creating variables to save number of G:U wobbles
  gu_seed <- 0
  gu_flank <- 0
  
  # For loop that goes and evaluates if target or miRNA sequence is a G:U wobble
  for (j in 1:aln_len) {
    nt_t <- substr(bp_target, j, j)
    nt_m <- substr(bp_miRNA, j, j)
    is_GU <- (nt_t == "G" & nt_m == "U") | (nt_t == "U" & nt_m == "G")
    
    if (j >= 2 && j <= 8) {
      gu_seed <- gu_seed + is_GU
    } else {
      gu_flank <- gu_flank + is_GU
    }
  }
  
  # Return as a data frame
  return(data.frame(
    target_id = target,
    mfe = mfe,
    p_value = pval,
    position = pos,
    GU_seed = gu_seed,
    GU_flank = gu_flank,
    stringsAsFactors = FALSE
  ))
}

result <- parse_rnahybrid_block(test_lines)
print(result)