# ~~~~~ DELETE NA COLUMNS ~~~~~~
# ===== Load libraries =====
library("tidyverse")
# ===== Importing diptera.csv =====
diptera <- read.table("databases/diptera.csv",
                      header = TRUE,
                      sep = ",")

# ===== Crear una función  que encuentre todas las columnas NA =====
all_col_NA <- function(df) {
  # Contar valores NA en cada columna
  na_counts <- colSums(is.na(df))
  # Identificar columnas con NA valores
  all_na_columns <- which(na_counts == nrow(df))
  # Obtener el nombre de las columnas
  all_na_column_names <- names(all_na_columns)
  print(all_na_column_names)
}

# ===== Usar función en díptera =====
all_col_NA(diptera)

# Borrar columna "ref7_link" del dataframe diptera
diptera$ref7_link <- NULL

# ===== Guardar nueva diptera =====
write.csv(diptera,
          "databases/diptera.csv",
          row.names = FALSE)