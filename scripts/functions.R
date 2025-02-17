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

# ==== Dataframe to FASTA ====
df_2_fasta <- function(df, file_name) {
  # Abrir conección con el archivo
  con <- file(file_name, open = "w")
  
  # Loop para cambiar de df a fasta
  for (i in 1:nrow(df)) {
    writeLines(paste0(">", df[i, 1]), con)  # Escribe el encabezado
    writeLines(df[i, 2], con)   # Escribe la secuencia
  }
  # Cerrar conección
  close(con)
}

# ==== Convert GRanges to dataframes =====
granges_to_df <- function(tx) {
  if (length(tx) > 0) {
    df <- as.data.frame(mcols(tx))  # Extract metadata columns and convert to data.frame
  } else {
    df <- data.frame()  # Create an empty data frame if no results are found
  }
}

}