# src/02_graficos.R
library(tidyverse)

data <- read_csv("data/dataset_limpio.csv")

# Gráfico 1: Demanda en el tiempo (Incidentes por día del mes)
g1 <- data %>%
  count(dia_mes) %>%
  ggplot(aes(x = dia_mes, y = n)) +
  geom_line(color = "blue", size = 1) +
  geom_point() +
  labs(title = "Demanda de incidentes por día del mes", x = "Día", y = "Cantidad de incidentes") +
  theme_minimal()
ggsave("figures/01_demanda_tiempo.png", plot = g1)

# Gráfico 2: Distribución (Por tipo de servicio)
g2 <- data %>%
  count(tipo_servicio) %>%
  ggplot(aes(x = reorder(tipo_servicio, n), y = n)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Incidentes por Tipo de Servicio", x = "", y = "Frecuencia") +
  theme_minimal()
ggsave("figures/02_distribucion_tipo.png", plot = g2)

# Gráfico 3: Comparación por Categoría (Top 10 Subtipos)
g3 <- data %>%
  count(subtipo) %>%
  top_n(10, n) %>%
  ggplot(aes(x = reorder(subtipo, n), y = n, fill = subtipo)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  labs(title = "Top 10 Subtipos de Incidentes", x = "", y = "Conteo") +
  theme_minimal()
ggsave("figures/03_comparacion_subtipo.png", plot = g3)

# Gráfico 4: Heatmap (Día de semana vs Tipo de servicio)
g4 <- data %>%
  count(dia_semana, tipo_servicio) %>%
  ggplot(aes(x = tipo_servicio, y = dia_semana, fill = n)) +
  geom_tile() +
  scale_fill_viridis_c() +
  labs(title = "Mapa de Calor: Intensidad por Día y Servicio", x = "Tipo de Servicio", y = "Día") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave("figures/04_heatmap.png", plot = g4)

# Gráfico 5: Distribución por Día de la Semana (nuevo, para análisis diario real)
g5 <- data %>%
  count(dia_semana) %>%
  ggplot(aes(x = dia_semana, y = n)) +
  geom_col(fill = "darkred") +
  labs(title = "Distribución de Incidentes por Día de la Semana", x = "Día", y = "Cantidad") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave("figures/05_distribucion_dia_semana.png", plot = g5)

# Gráfico 6: Tendencia temporal (por semana)
g6 <- data %>%
  mutate(semana = lubridate::week(fecha)) %>%
  count(semana) %>%
  ggplot(aes(x = semana, y = n)) +
  geom_line(color = "darkgreen", size = 1) +
  geom_point() +
  labs(title = "Tendencia de Incidentes por Semana", x = "Semana", y = "Cantidad") +
  theme_minimal()
ggsave("figures/06_tendencia_semanal.png", plot = g6)

print("Gráficos generados sin análisis de hora simulada.")
