# ~~~~~ FUSING DATA ~~~~~
# 
# ===== Load libraries =====
library("tidyverse")

# ===== Importing data =====
# Aedes aegypti
aae <- read.table("mirbase-diptera-scrapped/aae.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
# ===== Merging data =====
# Inspeccionar los dataframes para ver
# donde son iguales y en cuáles difieren
# Inspect lines
# lines <- readLines("yourfile.csv")
# cat(lines[95:105], sep = "\n")
# If you don't want to rename columns but still wish to combine the data frames, you can use mutate to add missing columns with NA.

# Example data frames with different column names
# df1 <- data.frame(A = 1:3, B = letters[1:3])
# df2 <- data.frame(X = 4:6, Y = letters[4:6])
# 
# # Add missing columns to each data frame
# df1 <- df1 %>% mutate(X = NA, Y = NA)
# df2 <- df2 %>% mutate(A = NA, B = NA)
# 
# # Combine data frames
# combined_df <- bind_rows(df1, df2)
# print(combined_df)

# Download merged csv and create another script
# to add more miRNAs from papers