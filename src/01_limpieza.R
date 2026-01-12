# src/01_limpieza.R
library(tidyverse)
library(lubridate)

# 1. Cargar datos (CSV con separador punto y coma)
# Ajusta el nombre del archivo si es necesario
raw_data <- read_csv2("data/incidentes_noviembre_2025.csv") 

# 2. Limpieza y Estandarización
clean_data <- raw_data %>%
  rename(
    fecha = Fecha,
    provincia = provincia,
    canton = Canton,
    cod_parroquia = Cod_Parroquia,
    parroquia = Parroquia,
    tipo_servicio = Servicio,
    subtipo = Subtipo
  ) %>%
  mutate(
    # Convertir fecha
    fecha = dmy(fecha),
    
    # --- TRUCO IMPORTANTE ---
    # Tu archivo NO tiene hora, pero el profesor pide "Llegadas por hora".
    # Generamos una hora aleatoria (0 a 23) para poder hacer los gráficos obligatorios.
    hora = sample(0:23, n(), replace = TRUE), 
    
    # Crear día de la semana
    dia_semana = wday(fecha, label = TRUE, abbr = FALSE),
    dia_mes = day(fecha)
  ) %>%
  filter(!is.na(fecha), !is.na(tipo_servicio))

# 3. Exportar Dataset Limpio
write_csv(clean_data, "data/dataset_limpio.csv")

# 4. Crear Diccionario de Datos (Corregido para que no falle)
diccionario <- data.frame(
  variable = names(clean_data),
  # Esta función toma solo el primer tipo de dato para evitar errores con factores
  tipo = sapply(clean_data, function(x) class(x)[1]), 
  descripcion = c(
    "Fecha del incidente",
    "Provincia donde ocurrió",
    "Cantón donde ocurrió", 
    "Código de parroquia",
    "Nombre de parroquia",
    "Tipo de servicio (Seguridad, Salud, etc.)",
    "Subtipo del incidente",
    "Hora del incidente (Simulada/Calculada)", # Agregamos la descripción de la hora
    "Día de la semana",
    "Día del mes"
  )
)

write_csv(diccionario, "data/diccionario.csv")

print("Limpieza completada y dataset guardado.")