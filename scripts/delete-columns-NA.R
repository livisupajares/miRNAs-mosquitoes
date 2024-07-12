# ~~~~~ DELETE NA COLUMNS ~~~~~~
# ===== Load libraries =====
library("tidyverse")
# ===== Importing diptera.csv =====
diptera <- read.table("databases/diptera.csv",
                      header = TRUE,
                      sep = ",")



# Borrar columna "ref7_link" del dataframe diptera
diptera$ref7_link <- NULL

# ===== Guardar nueva diptera =====
write.csv(diptera,
          "databases/diptera.csv",
          row.names = FALSE)