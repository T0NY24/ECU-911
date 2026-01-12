# Proyecto de Análisis y Simulación: ECU 911 (Grupo 3)

Este repositorio contiene el avance práctico del análisis de datos de llamadas de emergencia del ECU 911, correspondiente al **Grupo 3**. El objetivo es procesar datos reales (Noviembre 2025), visualizar patrones y extraer parámetros para una futura simulación.

**Integrantes:**
- Anthony Perez
- Franco Quezada
- Ricardo Rios

---

## Requisitos Previos e Instalación

Para ejecutar este proyecto correctamente en cualquier computadora, se requiere **R** y **RStudio**.

Antes de ejecutar el código, instale las librerías necesarias ejecutando el siguiente comando en la consola de RStudio:
```r
install.packages(c("tidyverse", "lubridate", "jsonlite", "shinydashboard", "rmarkdown", "knitr"))
```

---

## Instrucciones de Ejecución

El proyecto está automatizado para ser reproducible. Siga estos pasos:

### 1. Generar Análisis y Reportes (Automático)

Abra el archivo `00_run_all.R` en la raíz del proyecto y haga clic en el botón **Source** (o ejecute el código).

Este script maestro se encarga de:

1. **Limpiar los datos:** Ejecuta `src/01_limpieza.R` y genera dataset limpio con variables reales.
2. **Generar gráficos:** Ejecuta `src/02_graficos.R` y guarda 6 gráficos en `/figures`:
   - Demanda por día del mes
   - Distribución por tipo de servicio
   - Top 10 subtipos de incidentes
   - Heatmap (Día de semana vs Tipo de servicio)
   - Distribución por día de la semana
   - Tendencia temporal semanal
3. **Calcular parámetros:** Ejecuta `src/03_parametros.R` y exporta `data/params.json` con distribuciones reales.

### 2. Ver el Reporte Final

Una vez ejecutado el paso anterior, puede abrir el informe generado en:

- `reports/report.html` (Abrir en cualquier navegador web)

El reporte incluye análisis visual de patrones reales de emergencia sin simulación de datos.

### 3. Ejecutar el Dashboard Interactivo (Opcional)

Este proyecto incluye un dashboard interactivo desarrollado con Shiny para exploración de datos reales. Para visualizarlo:

1. Abra el archivo `dashboard/app.R`.
2. Haga clic en el botón verde **Run App** en la parte superior del editor de RStudio.
3. El dashboard permite:
   - Filtrar incidentes por tipo de servicio
   - Filtrar por día de la semana
   - Visualizar KPIs (total incidentes, cantón crítico, día pico)
   - Explorar gráficos interactivos de distribución y tendencia

---

## Estructura del Repositorio

A continuación se describe el contenido y la lógica de cada carpeta:

### `/data`
Contiene los datos crudos (`ECU911_original.csv`) y los procesados (`dataset_limpio.csv`, `params.json`).

### `/src`
Código fuente modular:

- **`01_limpieza.R`:** Carga el CSV (soporta separador `;`), estandariza columnas, extrae variables temporales (día de la semana, mes, año) de las fechas reales.
- **`02_graficos.R`:** Genera visualizaciones de demanda temporal, distribución por tipo, mapas de calor (Heatmaps) y análisis por día de la semana.
- **`03_parametros.R`:** Calcula tasas de llegada (lambda), distribuciones reales por día de semana y probabilidades para la simulación.

### `/figures`
Almacena los gráficos en formato PNG generados por el código.

### `/reports`
Contiene el archivo RMarkdown (`.Rmd`) y el reporte compilado (`.html`).

### `/dashboard`
Contiene la aplicación Shiny (`app.R`) para exploración interactiva de datos.

### `00_run_all.R`
Script orquestador que ejecuta todo el flujo de trabajo en orden secuencial.

---

## Notas sobre los Datos

- **Fuente:** Datos abiertos del ECU 911 (Noviembre 2025).
- **Tratamiento:** Se realizó una limpieza de nombres de columnas y formateo de fechas.
- **Análisis Temporal:** Se extraen variables reales de las fechas (día de la semana, mes, año) para análisis auténticos sin simulación.
- **Precisión:** Todos los patrones identificados se basan en datos verificables, permitiendo análisis confiables de demanda y optimización de recursos.

---

## Capacidades Principales

✅ **Análisis de demanda real** - Patrones auténticos sin simulación  
✅ **Optimización de recursos** - Basada en datos verificables  
✅ **Evaluación de políticas** - Con información precisa  
✅ **Predicción de demanda** - Modelos sin sesgo de datos simulados  

---

**Enero 2026**  
UIDE