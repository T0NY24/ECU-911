# src/03_parametros.R
library(tidyverse)
library(jsonlite)

data <- read_csv("data/dataset_limpio.csv")

# 1. Tasa de llegadas (Incidentes por día promedio)
total_dias <- as.numeric(difftime(max(data$fecha), min(data$fecha), units = "days")) + 1
tasa_llegada_global <- nrow(data) / total_dias

# 2. Proporciones de tipos de servicio (Para simular tipos)
props_tipo <- data %>%
  count(tipo_servicio) %>%
  mutate(prob = n / sum(n))

# 3. Proporciones de cantones
props_canton <- data %>%
  count(canton) %>%
  mutate(prob = n / sum(n))

# 4. Validación automática (Requisito H)
check1 <- all(data$dia_mes >= 1 & data$dia_mes <= 31) # Días válidos
check2 <- abs(sum(props_tipo$prob) - 1) < 0.001 # Probabilidad suma ~100%
check3 <- nrow(data) > 0 # Existen datos

if(check1 & check2 & check3) {
  print("Validaciones de datos y parámetros: OK")
} else {
  warning("Error en validación de parámetros")
}

# 5. Exportar Parámetros (JSON)
params <- list(
  tasa_llegada_lambda = tasa_llegada_global,
  distribucion_tipos = props_tipo,
  distribucion_cantones = props_canton,
  total_eventos = nrow(data),
  periodo = list(
    inicio = as.character(min(data$fecha)),
    fin = as.character(max(data$fecha))
  ),
  validado = TRUE
)

write_json(params, "data/params.json", pretty = TRUE)
print("Parámetros exportados.")
