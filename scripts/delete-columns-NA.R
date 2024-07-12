# ~~~~~ DELETE NA COLUMNS ~~~~~~
# ===== Load libraries =====
library("tidyverse")
# ===== Importing diptera.csv =====
diptera <- read.table("databases/diptera.csv",
                      header = TRUE,
                      sep = ",")
# ===== Encontrar columnas con valores NA =====
# Contar valores NA en cada columna
na_counts <- colSums(is.na(diptera))

# Identificar columnas con NA valores
all_na_columns <- which(na_counts == nrow(diptera))

# Obtener el nombre de las columnas
all_na_column_names <- names(all_na_columns)
print(all_na_column_names)

