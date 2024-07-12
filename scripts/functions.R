# ~~~~~ FUNCTIONS ~~~~~
# ===== Crear una función  que encuentre todas las columnas NA =====
delete_empty_cols <- function(df) {
  # Contar valores NA en cada columna
  na_counts <- colSums(is.na(df))
  
  # Identificar columnas con NA valores
  all_na_columns <- which(na_counts == nrow(df))
  
  # Obtener el nombre de las columnas
  all_na_column_names <- names(all_na_columns)
  cat("Columns without any value\n", all_na_column_names, "\n")
  
  # Borrar problematic columns
  df <- df[, !names(df) %in% all_na_column_names]
  
  # Retornar el dataframe modificado
  return(df)
}