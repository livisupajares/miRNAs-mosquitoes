# ~~~~~ FUNCTIONS ~~~~~
library(dplyr)
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
    writeLines(paste0(">", df[i, 1]), con) # Escribe el encabezado
    writeLines(df[i, 2], con) # Escribe la secuencia
  }
  # Cerrar conección
  close(con)
}

# ==== Convert GRanges to dataframes =====
granges_to_df <- function(tx) {
  if (length(tx) > 0) {
    df <- as.data.frame(mcols(tx)) # Extract metadata columns and convert to data.frame
  } else {
    df <- data.frame() # Create an empty data frame if no results are found
  }
}

# ==== Merge transcript name ensembl with results df ====
merge_ensembl_to_df <- function(df, original) {
  # Ensure `df` exists and contains transcript information
  if (exists("df") && nrow(df) > 0) {
    # Merge both dataframes by matching `transcript_id` with `tx_id`
    tcontrol <- merge(original, df, by.x = "mRNA", by.y = "tx_id", all.x = TRUE)
  } else {
    tcontrol <- original # If df is empty, keep only transcript_id_df
  }
}

# ==== Reorder columns ====
# Function to move the last two columns between the first and second column
reorder_columns <- function(df) {
  # Get the column names
  col_names <- colnames(df)
  # Identify the last two columns
  last_two <- col_names[(ncol(df) - 1):ncol(df)]
  # Reorder columns: first column, last two columns, then the rest
  df_reordered <- df %>%
    dplyr::select(1, all_of(last_two), everything())
  return(df_reordered)
}

# ==== Calculate Fold Enrichment from strength values (STRINGDB) ====
calculate_fold_enrichment <- function(strength) {
  return(10^strength)
}
