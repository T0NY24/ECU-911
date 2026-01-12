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

1. **Limpiar los datos:** Ejecuta `src/01_limpieza.R`.
2. **Generar gráficos:** Ejecuta `src/02_graficos.R` y guarda las imágenes en `/figures`.
3. **Calcular parámetros:** Ejecuta `src/03_parametros.R` y exporta `data/params.json`.

### 2. Ver el Reporte Final

Una vez ejecutado el paso anterior, puede abrir el informe generado en:

- `reports/Informe_Avance.html` (Abrir en cualquier navegador web)

### 3. Ejecutar el Dashboard Interactivo (Opcional)

Este proyecto incluye un dashboard interactivo desarrollado con Shiny. Para visualizarlo:

1. Abra el archivo `dashboard/app.R`.
2. Haga clic en el botón verde **Run App** en la parte superior del editor de RStudio.

---

## Estructura del Repositorio

A continuación se describe el contenido y la lógica de cada carpeta:

### `/data`
Contiene los datos crudos (`ECU911_original.csv`) y los procesados (`dataset_limpio.csv`, `params.json`).

### `/src`
Código fuente modular:

- **`01_limpieza.R`:** Carga el CSV (soporta separador `;`), estandariza columnas y simula la hora de llegada (dado que el dataset público original carecía de hora HH:MM).
- **`02_graficos.R`:** Genera visualizaciones de demanda temporal, distribución por tipo y mapas de calor (Heatmaps).
- **`03_parametros.R`:** Calcula tasas de llegada (lambda) y probabilidades de ruteo para la simulación.

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
- **Supuestos:** Para cumplir con el requisito de análisis por hora, se generó una distribución horaria aleatoria uniforme, ya que la base de datos pública descargada solo contenía la fecha (DD/MM/YYYY).

---

**Enero 2026**  
UIDE