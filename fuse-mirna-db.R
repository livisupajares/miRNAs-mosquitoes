# ~~~~~ FUSING DATA ~~~~~
# 
# ===== Load libraries =====
library("tidyverse")

# ===== Importing data =====
# Drosophila Melanogaster --> more variables, todas tienen que tener el mismo
# número de variables
dme <- read.table("mirbase-diptera-scrapped/dme.csv",
                  header = TRUE,
                  sep = ",",
                  quote = "\"", 
                  fill = TRUE,
                  na.strings = c(NA, "Unknown"))
# Aedes aegypti
aae <- read.table("mirbase-diptera-scrapped/aae.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
## Añadir columnas que tiene dme
aae <- aae %>% 
  mutate(db_link1 = NA,
                      db_link2 = NA,
                      db_link3 = NA,
                      mat1_db_link = NA,
                      mat1_pred_target_link = NA,
                      mat2_db_link = NA,
                      mat2_pred_target_link = NA,
                      ref3_link = NA,
                      ref4_link = NA,
                      ref5_link = NA,
                      ref6_link = NA,
                      ref7_link = NA)
## Moviendo columnas para igualar dme
aae <- aae %>%
  relocate(db_link1:db_link3, 
           .after = comment_conf) %>%
  relocate(mat1_db_link:mat1_pred_target_link,
           .after = evidence1) %>%
  relocate(mat2_db_link:mat2_pred_target_link,
           .after = evidence2) %>%
  relocate(ref3_link:ref7_link,
           .after = ref2_link)
# Anopheles gambiae
aga <- read.table("mirbase-diptera-scrapped/aga.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
## Añadir columnas que tiene dme
aga <- aga %>% mutate(db_link1 = NA,
                      db_link2 = NA,
                      db_link3 = NA,
                      mat1_db_link = NA,
                      mat1_pred_target_link = NA,
                      mat2_db_link = NA,
                      mat2_pred_target_link = NA,
                      ref3_link = NA,
                      ref4_link = NA,
                      ref5_link = NA,
                      ref6_link = NA,
                      ref7_link = NA)
## Moviendo columnas para igualar dme
aga <- aga %>%
  relocate(db_link1:db_link3, 
           .after = comment_conf) %>%
  relocate(mat1_db_link:mat1_pred_target_link,
           .after = evidence1) %>%
  relocate(mat2_db_link:mat2_pred_target_link,
           .after = evidence2) %>%
  relocate(ref3_link:ref7_link,
           .after = ref2_link)
# Bactrocera dorsalis
bdo <- read.table("mirbase-diptera-scrapped/bdo.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
## Añadir columnas que tiene dme
bdo <- bdo %>% mutate(db_link1 = NA,
                      db_link2 = NA,
                      db_link3 = NA,
                      mat1_db_link = NA,
                      mat1_pred_target_link = NA,
                      mat2_db_link = NA,
                      mat2_pred_target_link = NA,
                      ref3_link = NA,
                      ref4_link = NA,
                      ref5_link = NA,
                      ref6_link = NA,
                      ref7_link = NA)
## Moviendo columnas para igualar dme
bdo <- bdo %>%
  relocate(db_link1:db_link3, 
           .after = comment_conf) %>%
  relocate(mat1_db_link:mat1_pred_target_link,
           .after = evidence1) %>%
  relocate(mat2_db_link:mat2_pred_target_link,
           .after = evidence2) %>%
  relocate(ref3_link:ref7_link,
           .after = ref2_link)
# Culex quinquefasciatus
cqu <- read.table("mirbase-diptera-scrapped/cqu.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
## Añadir columnas que tiene dme
cqu <- cqu %>% mutate(db_link1 = NA,
                      db_link2 = NA,
                      db_link3 = NA,
                      mat1_db_link = NA,
                      mat1_pred_target_link = NA,
                      mat2_db_link = NA,
                      mat2_pred_target_link = NA,
                      ref3_link = NA,
                      ref4_link = NA,
                      ref5_link = NA,
                      ref6_link = NA,
                      ref7_link = NA)
## Moviendo columnas para igualar dme
cqu <- cqu %>%
  relocate(db_link1:db_link3, 
           .after = comment_conf) %>%
  relocate(mat1_db_link:mat1_pred_target_link,
           .after = evidence1) %>%
  relocate(mat2_db_link:mat2_pred_target_link,
           .after = evidence2) %>%
  relocate(ref3_link:ref7_link,
           .after = ref2_link)
# Drosophila ananassae
dan <- read.table("mirbase-diptera-scrapped/dan.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
## Añadir columnas que tiene dme
dan <- dan %>% mutate(db_link1 = NA,
                      db_link2 = NA,
                      db_link3 = NA,
                      mat1_db_link = NA,
                      mat1_pred_target_link = NA,
                      mat2_db_link = NA,
                      mat2_pred_target_link = NA,
                      ref3_link = NA,
                      ref4_link = NA,
                      ref5_link = NA,
                      ref6_link = NA,
                      ref7_link = NA)
## Moviendo columnas para igualar dme
dan <- dan %>%
  relocate(db_link1:db_link3, 
           .after = comment_conf) %>%
  relocate(mat1_db_link:mat1_pred_target_link,
           .after = evidence1) %>%
  relocate(mat2_db_link:mat2_pred_target_link,
           .after = evidence2) %>%
  relocate(ref3_link:ref7_link,
           .after = ref2_link)
# Drosophila erecta
der <- read.table("mirbase-diptera-scrapped/der.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
## Añadir columnas que tiene dme
der <- der %>% mutate(db_link1 = NA,
                      db_link2 = NA,
                      db_link3 = NA,
                      mat1_db_link = NA,
                      mat1_pred_target_link = NA,
                      mat2_db_link = NA,
                      mat2_pred_target_link = NA,
                      ref3_link = NA,
                      ref4_link = NA,
                      ref5_link = NA,
                      ref6_link = NA,
                      ref7_link = NA)
## Moviendo columnas para igualar dme
der <- der %>%
  relocate(db_link1:db_link3, 
           .after = comment_conf) %>%
  relocate(mat1_db_link:mat1_pred_target_link,
           .after = evidence1) %>%
  relocate(mat2_db_link:mat2_pred_target_link,
           .after = evidence2) %>%
  relocate(ref3_link:ref7_link,
           .after = ref2_link)
# Drosophila grimshawi
dgr <- read.table("mirbase-diptera-scrapped/dgr.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
## Añadir columnas que tiene dme
dgr <- dgr %>% mutate(db_link1 = NA,
                      db_link2 = NA,
                      db_link3 = NA,
                      mat1_db_link = NA,
                      mat1_pred_target_link = NA,
                      mat2_db_link = NA,
                      mat2_pred_target_link = NA,
                      ref3_link = NA,
                      ref4_link = NA,
                      ref5_link = NA,
                      ref6_link = NA,
                      ref7_link = NA)
## Moviendo columnas para igualar dme
dgr <- dgr %>%
  relocate(db_link1:db_link3, 
           .after = comment_conf) %>%
  relocate(mat1_db_link:mat1_pred_target_link,
           .after = evidence1) %>%
  relocate(mat2_db_link:mat2_pred_target_link,
           .after = evidence2) %>%
  relocate(ref3_link:ref7_link,
           .after = ref2_link)
# Drosophila mojavensis
dmo <- read.table("mirbase-diptera-scrapped/dmo.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
## Añadir columnas que tiene dme
dmo <- dmo %>% mutate(db_link1 = NA,
                      db_link2 = NA,
                      db_link3 = NA,
                      mat1_db_link = NA,
                      mat1_pred_target_link = NA,
                      mat2_db_link = NA,
                      mat2_pred_target_link = NA,
                      ref3_link = NA,
                      ref4_link = NA,
                      ref5_link = NA,
                      ref6_link = NA,
                      ref7_link = NA)
## Moviendo columnas para igualar dme
dmo <- dmo %>%
  relocate(db_link1:db_link3, 
           .after = comment_conf) %>%
  relocate(mat1_db_link:mat1_pred_target_link,
           .after = evidence1) %>%
  relocate(mat2_db_link:mat2_pred_target_link,
           .after = evidence2) %>%
  relocate(ref3_link:ref7_link,
           .after = ref2_link)
# Drosophila persimilis
dpe <- read.table("mirbase-diptera-scrapped/dpe.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
## Añadir columnas que tiene dme
dpe <- dpe %>% mutate(db_link1 = NA,
                      db_link2 = NA,
                      db_link3 = NA,
                      mat1_db_link = NA,
                      mat1_pred_target_link = NA,
                      mat2_db_link = NA,
                      mat2_pred_target_link = NA,
                      ref3_link = NA,
                      ref4_link = NA,
                      ref5_link = NA,
                      ref6_link = NA,
                      ref7_link = NA)
## Moviendo columnas para igualar dme
dpe <- dpe %>%
  relocate(db_link1:db_link3, 
           .after = comment_conf) %>%
  relocate(mat1_db_link:mat1_pred_target_link,
           .after = evidence1) %>%
  relocate(mat2_db_link:mat2_pred_target_link,
           .after = evidence2) %>%
  relocate(ref3_link:ref7_link,
           .after = ref2_link)
# Drosophila pseudoobscura
dps <- read.table("mirbase-diptera-scrapped/dps.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
## Añadir columnas que tiene dme
dps <- dps %>% mutate(db_link1 = NA,
                      db_link2 = NA,
                      db_link3 = NA,
                      mat1_db_link = NA,
                      mat1_pred_target_link = NA,
                      mat2_db_link = NA,
                      mat2_pred_target_link = NA,
                      ref3_link = NA,
                      ref4_link = NA,
                      ref5_link = NA,
                      ref6_link = NA,
                      ref7_link = NA)
## Moviendo columnas para igualar dme
dps <- dps %>%
  relocate(db_link1:db_link3, 
           .after = comment_conf) %>%
  relocate(mat1_db_link:mat1_pred_target_link,
           .after = evidence1) %>%
  relocate(mat2_db_link:mat2_pred_target_link,
           .after = evidence2) %>%
  relocate(ref3_link:ref7_link,
           .after = ref2_link)
# Drosophila sechellia
dse <- read.table("mirbase-diptera-scrapped/dse.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
## Añadir columnas que tiene dme
dse <- dse %>% mutate(db_link1 = NA,
                      db_link2 = NA,
                      db_link3 = NA,
                      mat1_db_link = NA,
                      mat1_pred_target_link = NA,
                      mat2_db_link = NA,
                      mat2_pred_target_link = NA,
                      ref3_link = NA,
                      ref4_link = NA,
                      ref5_link = NA,
                      ref6_link = NA,
                      ref7_link = NA)
## Moviendo columnas para igualar dme
dse <- dse %>%
  relocate(db_link1:db_link3, 
           .after = comment_conf) %>%
  relocate(mat1_db_link:mat1_pred_target_link,
           .after = evidence1) %>%
  relocate(mat2_db_link:mat2_pred_target_link,
           .after = evidence2) %>%
  relocate(ref3_link:ref7_link,
           .after = ref2_link)
# Drosophila simulans
dsi <- read.table("mirbase-diptera-scrapped/dsi.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
## Añadir columnas que tiene dme
dsi <- dsi %>% mutate(db_link1 = NA,
                      db_link2 = NA,
                      db_link3 = NA,
                      mat1_db_link = NA,
                      mat1_pred_target_link = NA,
                      mat2_db_link = NA,
                      mat2_pred_target_link = NA,
                      ref3_link = NA,
                      ref4_link = NA,
                      ref5_link = NA,
                      ref6_link = NA,
                      ref7_link = NA)
## Moviendo columnas para igualar dme
dsi <- dsi %>%
  relocate(db_link1:db_link3, 
           .after = comment_conf) %>%
  relocate(mat1_db_link:mat1_pred_target_link,
           .after = evidence1) %>%
  relocate(mat2_db_link:mat2_pred_target_link,
           .after = evidence2) %>%
  relocate(ref3_link:ref7_link,
           .after = ref2_link)
# Drosophila virilis
dvi <- read.table("mirbase-diptera-scrapped/dvi.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
## Añadir columnas que tiene dme
dvi <- dvi %>% mutate(db_link1 = NA,
                      db_link2 = NA,
                      db_link3 = NA,
                      mat1_db_link = NA,
                      mat1_pred_target_link = NA,
                      mat2_db_link = NA,
                      mat2_pred_target_link = NA,
                      ref3_link = NA,
                      ref4_link = NA,
                      ref5_link = NA,
                      ref6_link = NA,
                      ref7_link = NA)
## Moviendo columnas para igualar dme
dvi <- dvi %>%
  relocate(db_link1:db_link3, 
           .after = comment_conf) %>%
  relocate(mat1_db_link:mat1_pred_target_link,
           .after = evidence1) %>%
  relocate(mat2_db_link:mat2_pred_target_link,
           .after = evidence2) %>%
  relocate(ref3_link:ref7_link,
           .after = ref2_link)
# Drosophila willistoni
dwi <- read.table("mirbase-diptera-scrapped/dwi.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
## Añadir columnas que tiene dme
dwi <- dwi %>% mutate(db_link1 = NA,
                      db_link2 = NA,
                      db_link3 = NA,
                      mat1_db_link = NA,
                      mat1_pred_target_link = NA,
                      mat2_db_link = NA,
                      mat2_pred_target_link = NA,
                      ref3_link = NA,
                      ref4_link = NA,
                      ref5_link = NA,
                      ref6_link = NA,
                      ref7_link = NA)
## Moviendo columnas para igualar dme
dwi <- dwi %>%
  relocate(db_link1:db_link3, 
           .after = comment_conf) %>%
  relocate(mat1_db_link:mat1_pred_target_link,
           .after = evidence1) %>%
  relocate(mat2_db_link:mat2_pred_target_link,
           .after = evidence2) %>%
  relocate(ref3_link:ref7_link,
           .after = ref2_link)
# Drosophila yakuba
dya <- read.table("mirbase-diptera-scrapped/dya.csv",
                  header = TRUE,
                  sep = ",",
                  na.strings = c(NA, "Unknown"))
## Añadir columnas que tiene dme
dya <- dya %>% mutate(db_link1 = NA,
                      db_link2 = NA,
                      db_link3 = NA,
                      mat1_db_link = NA,
                      mat1_pred_target_link = NA,
                      mat2_db_link = NA,
                      mat2_pred_target_link = NA,
                      ref3_link = NA,
                      ref4_link = NA,
                      ref5_link = NA,
                      ref6_link = NA,
                      ref7_link = NA)
## Moviendo columnas para igualar dme
dya <- dya %>%
  relocate(db_link1:db_link3, 
           .after = comment_conf) %>%
  relocate(mat1_db_link:mat1_pred_target_link,
           .after = evidence1) %>%
  relocate(mat2_db_link:mat2_pred_target_link,
           .after = evidence2) %>%
  relocate(ref3_link:ref7_link,
           .after = ref2_link)
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