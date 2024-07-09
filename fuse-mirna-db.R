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
# Anopheles gambiae
aga <- read.table("mirbase-diptera-scrapped/aga.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
# Bactrocera dorsalis
bdo <- read.table("mirbase-diptera-scrapped/bdo.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
# Culex quinquefasciatus
cqu <- read.table("mirbase-diptera-scrapped/cqu.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
# Drosophila ananassae
dan <- read.table("mirbase-diptera-scrapped/dan.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
# Drosophila erecta
der <- read.table("mirbase-diptera-scrapped/der.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
# Drosophila grimshawi
dgr <- read.table("mirbase-diptera-scrapped/dgr.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
# Drosophila Melanogaster --> more variables
dme <- read.table("mirbase-diptera-scrapped/dme.csv",
                  header = TRUE,
                  sep = ",",
                  quote = "\"", 
                  fill = TRUE,
                  na.strings = c(NA, "Unknown"))
# Drosophila mojavensis
dmo <- read.table("mirbase-diptera-scrapped/dmo.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
# Drosophila persimilis
dpe <- read.table("mirbase-diptera-scrapped/dpe.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
# Drosophila pseudoobscura
dps <- read.table("mirbase-diptera-scrapped/dps.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
# Drosophila sechellia
dse <- read.table("mirbase-diptera-scrapped/dse.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
# Drosophila simulans
dsi <- read.table("mirbase-diptera-scrapped/dsi.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
# Drosophila virilis
dvi <- read.table("mirbase-diptera-scrapped/dvi.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
# Drosophila willistoni
dwi <- read.table("mirbase-diptera-scrapped/dwi.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
# Drosophila yakuba
dya <- read.table("mirbase-diptera-scrapped/dya.csv",
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