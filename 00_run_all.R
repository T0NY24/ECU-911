# 00_run_all.R
# Este script ejecuta todo el flujo de trabajo del Grupo 3

message("Iniciando proceso ECU 911...")

source("src/01_limpieza.R")
message("1. Limpieza finalizada.")

source("src/02_graficos.R")
message("2. Gráficos generados en /figures.")

source("src/03_parametros.R")
message("3. Parámetros calculados en /data.")

message("¡Proyecto ejecutado con éxito!")

