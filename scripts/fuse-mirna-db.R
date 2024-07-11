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

## Reordenar columnas para que coincidan con dme (referencia)
aae <- aae %>%
  select(names(dme))

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
  select(names(dme))

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
  select(names(dme))

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
  select(names(dme))

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
  select(names(dme))

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
  select(names(dme))

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
  select(names(dme))

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
  select(names(dme))

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
  select(names(dme))

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
  select(names(dme))

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
  select(names(dme))

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
  select(names(dme))

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
  select(names(dme))

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
  select(names(dme))

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
  select(names(dme))

# ===== Merging data =====
# 
# # Formar la base de datos díptera
diptera <- bind_rows(aae,
                     aga,
                     bdo,
                     cqu,
                     dan,
                     der,
                     dgr,
                     dme,
                     dmo,
                     dpe,
                     dps,
                     dse,
                     dsi,
                     dvi,
                     dwi,
                     dya)

# Download merged csv and create another script
# to add more miRNAs from papers
write.csv(diptera,
          "/home/cayetano/livisu/git/miRNAs-mosquitoes/diptera.csv",
          row.names = FALSE)