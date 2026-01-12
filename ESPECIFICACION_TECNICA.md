# ESPECIFICACIÓN TÉCNICA - Corrección de Datos ECU-911

## Problema Original
El sistema estaba **generando hora aleatoria** con la línea:
```r
hora = sample(0:23, n(), replace = TRUE)
```

Esta simulación causaba:
- ❌ Pérdida de precisión en análisis
- ❌ Distorsión de patrones reales
- ❌ Imposibilidad de análisis confiables de tiempos de respuesta
- ❌ Datos no verificables

## Solución Implementada

Se removió completamente la simulación y se estructura el análisis alrededor de **datos reales de fechas**.

---

## CAMBIOS TÉCNICOS DETALLADOS

### 1. Limpieza de Datos (src/01_limpieza.R)

#### Antes (con simulación):
```r
mutate(
  fecha = dmy(fecha),
  hora = sample(0:23, n(), replace = TRUE),  # ← REMOVIDA
  dia_semana = wday(fecha, label = TRUE, abbr = FALSE),
  dia_mes = day(fecha)
)
```

#### Después (datos reales):
```r
mutate(
  fecha = dmy(fecha),
  dia_semana = wday(fecha, label = TRUE, abbr = FALSE),
  dia_mes = day(fecha),
  mes = month(fecha),        # ← NUEVO
  año = year(fecha)          # ← NUEVO
)
```

#### Variables del Dataset
**Anteriormente (10 variables):**
- fecha, provincia, canton, cod_parroquia, parroquia, tipo_servicio, subtipo, **hora**, dia_semana, dia_mes

**Actualmente (11 variables):**
- fecha, provincia, canton, cod_parroquia, parroquia, tipo_servicio, subtipo, dia_semana, dia_mes, **mes**, **año**

---

### 2. Gráficos (src/02_graficos.R)

#### Removidos:
- Análisis horario (no hay datos horarios)

#### Agregados:
- **Gráfico 5**: Distribución por día de la semana
  ```r
  data %>%
    count(dia_semana) %>%
    ggplot(aes(x = dia_semana, y = n)) +
    geom_col(fill = "darkred") +
    labs(title = "Distribución de Incidentes por Día de la Semana")
  ```

- **Gráfico 6**: Tendencia temporal semanal
  ```r
  data %>%
    mutate(semana = lubridate::week(fecha)) %>%
    count(semana) %>%
    ggplot(aes(x = semana, y = n)) +
    geom_line(color = "darkgreen", size = 1) +
    geom_point() +
    labs(title = "Tendencia de Incidentes por Semana")
  ```

---

### 3. Parámetros (src/03_parametros.R)

#### Nueva distribución agregada:
```r
props_dia_semana <- data %>%
  count(dia_semana) %>%
  mutate(prob = n / sum(n))
```

#### Parámetros en JSON:
```json
{
  "tasa_llegada_lambda": 8968.8667,
  "total_incidentes": 269066,
  "distribucion_tipos": {...},
  "distribucion_cantones": {...},
  "distribucion_dia_semana": [
    {"dia_semana": "Monday", "n": 32877, "prob": 0.1222},
    {"dia_semana": "Tuesday", "n": 30209, "prob": 0.1123},
    ...
  ],
  "periodo": {
    "inicio": "2025-11-01",
    "fin": "2025-11-30",
    "total_dias": 30
  },
  "nota": "Parámetros basados en datos reales sin simulación de hora"
}
```

---

### 4. Dashboard (dashboard/app.R)

#### UI Changes:

**Removido:**
```r
sliderInput("filtro_hora", "Rango de Horas:",
            min = 0, max = 23, value = c(0, 23))
```

**Agregado:**
```r
selectInput("filtro_dia_semana", "Filtrar por Día de Semana:",
            choices = c("Todos", sort(unique(as.character(data$dia_semana)))))
```

#### KPI Changes:

**Removido:**
```r
output$kpi_hora_pico <- renderValueBox({
  top_hora <- data_filtrada() %>% count(hora, sort = TRUE) %>% slice(1) %>% pull(hora)
  # ...
})
```

**Agregado:**
```r
output$kpi_dia_pico <- renderValueBox({
  top_dia <- data_filtrada() %>% count(dia_semana, sort = TRUE) %>% slice(1) %>% pull(dia_semana)
  valueBox(as.character(top_dia), "Día Pico", icon = icon("calendar"), color = "blue")
})
```

#### Gráficos:

**Removido:**
```r
output$plot_linea <- renderPlot({
  data_filtrada() %>%
    count(hora) %>%
    ggplot(aes(x = hora, y = n)) +
    geom_line(color = "darkred", size = 1.2)
})
```

**Agregados:**
```r
output$plot_dias <- renderPlot({
  data_filtrada() %>%
    count(dia_semana) %>%
    ggplot(aes(x = dia_semana, y = n)) +
    geom_col(fill = "darkred")
})

output$plot_tendencia <- renderPlot({
  data_filtrada() %>%
    mutate(semana = lubridate::week(fecha)) %>%
    count(semana) %>%
    ggplot(aes(x = semana, y = n)) +
    geom_line(color = "darkgreen", size = 1)
})
```

---

## ESTADÍSTICAS DE DATOS

| Métrica | Valor |
|---------|-------|
| Total de incidentes | 269,066 |
| Período | 1-30 nov 2025 (30 días) |
| Tasa promedio | 8,968.87 incidentes/día |
| Provincia con más incidentes | Pichincha (Quito) - 57,059 |
| Canton con más incidentes | Guayaquil - 49,850 |
| Tipo de servicio mayoritario | Seguridad Ciudadana - 67.55% |
| Tipo de servicio minoritario | Gestión de Riesgos - 0.37% |

### Distribución por Día de Semana (Real)
```
Monday:    32,877 (12.22%)
Tuesday:   30,209 (11.23%)
Wednesday: 31,492 (11.70%)
Thursday:  32,401 (12.04%)
Friday:    36,444 (13.54%)
Saturday:  50,763 (18.87%)
Sunday:    54,880 (20.40%)
```

**Observación**: Mayor demanda en fin de semana (viernes-domingo) con 52.81% de incidentes.

---

## IMPACTO EN ANÁLISIS

### Análisis Temporal Anterior (con simulación)
- ❌ Horas distribuidas aleatoriamente
- ❌ No representan patrones reales
- ❌ Imposible identificar horas pico auténticas
- ❌ Modelos de predicción sesgados

### Análisis Temporal Actual (datos reales)
- ✅ Patrones auténticos por día de la semana
- ✅ Distribución real de incidentes
- ✅ Identificación confiable de picos de demanda
- ✅ Modelos predictivos basados en evidencia

---

## ARCHIVOS GENERADOS

### Dataset Principal
- **Ubicación**: `data/dataset_limpio.csv`
- **Formato**: CSV con 269,066 filas + encabezado
- **Tamaño**: ~37 MB
- **Encoding**: UTF-8
- **Delimitador**: Coma (,)

### Gráficos (PNG, 300 DPI)
1. `figures/01_demanda_tiempo.png` (139 KB)
2. `figures/02_distribucion_tipo.png` (76 KB)
3. `figures/03_comparacion_subtipo.png` (96 KB)
4. `figures/04_heatmap.png` (154 KB)
5. `figures/05_distribucion_dia_semana.png` (79 KB)
6. `figures/06_tendencia_semanal.png` (107 KB)

### Metadatos
- **Ubicación**: `data/diccionario.csv`
- **Contenido**: 11 variables con descripción de cada una

### Parámetros
- **Ubicación**: `data/params.json`
- **Formato**: JSON estructurado
- **Contenido**: Distribuciones y tasas para simulación

---

## VALIDACIÓN Y TESTS

### Validaciones Automáticas (OK)
✓ Fechas válidas (1-30 de noviembre)
✓ Probabilidades suman ~100%
✓ Datos presentes (n > 0)
✓ Variables esperadas presentes

### Verificaciones Manuales
✓ Sin valores NaN en fecha
✓ Sin valores NaN en tipo_servicio
✓ Sin columna "hora" en dataset limpio
✓ Todos los gráficos generados
✓ JSON válido y estructurado

---

## COMPATIBILIDAD

### R Packages Requeridos
- `tidyverse` (ggplot2, dplyr, readr, etc.)
- `lubridate` (para procesamiento de fechas)
- `jsonlite` (para exportar parámetros)
- `shiny` + `shinydashboard` (para dashboard)

### Versiones Testeadas
- R: 4.0+
- tidyverse: 2.0.0
- ggplot2: 4.0.1
- lubridate: 1.9.4

---

## CONCLUSIÓN

La eliminación de la simulación de hora garantiza que:

1. **Precisión**: Los análisis se basan en datos verificables
2. **Confiabilidad**: Los patrones identificados son reales
3. **Reproducibilidad**: Otros analistas pueden verificar los resultados
4. **Validez**: Los modelos predictivos tendrán base sólida

El proyecto ECU-911 ahora está listo para análisis profesionales de demanda de emergencias sin sesgos de datos simulados.

---

**Documento técnico preparado**: 12 de enero de 2026  
**Versión**: 1.0  
**Estado**: Validado

