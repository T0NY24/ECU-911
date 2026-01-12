# dashboard/app.R
library(shiny)
library(shinydashboard)
library(tidyverse)

# 1. Cargar datos (Busca el archivo en la carpeta data que está un nivel arriba)
tryCatch({
  data <- read_csv("../data/dataset_limpio.csv")
}, error = function(e) {
  # Fallback por si corres la app desde otra ruta
  data <- read_csv("data/dataset_limpio.csv")
})

# 2. Interfaz de Usuario (UI)
ui <- dashboardPage(
  skin = "red", # Color rojo estilo ECU 911
  dashboardHeader(title = "Dashboard ECU 911 - G3"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Panel Principal", tabName = "dashboard", icon = icon("dashboard")),
      
      # --- FILTROS ---
      selectInput("filtro_servicio", "Filtrar por Servicio:", 
                  choices = c("Todos", unique(data$tipo_servicio))),
      
      selectInput("filtro_dia_semana", "Filtrar por Día de Semana:",
                  choices = c("Todos", sort(unique(as.character(data$dia_semana)))))
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
              # --- PRIMERA FILA: KPIs (Indicadores Clave) ---
              fluidRow(
                valueBoxOutput("kpi_total", width = 4),
                valueBoxOutput("kpi_canton", width = 4),
                valueBoxOutput("kpi_dia_pico", width = 4)
              ),
              
              # --- SEGUNDA FILA: GRÁFICOS ---
              fluidRow(
                box(title = "Top Subtipos de Emergencia (Filtrado)", status = "primary", solidHeader = TRUE,
                    plotOutput("plot_barras", height = 300)),
                
                box(title = "Distribución por Día de la Semana", status = "warning", solidHeader = TRUE,
                    plotOutput("plot_dias", height = 300))
              ),
              
              # --- TERCERA FILA: GRÁFICOS ADICIONALES ---
              fluidRow(
                box(title = "Incidentes por Tipo de Servicio", status = "success", solidHeader = TRUE,
                    plotOutput("plot_servicio", height = 300)),
                
                box(title = "Tendencia Temporal", status = "info", solidHeader = TRUE,
                    plotOutput("plot_tendencia", height = 300))
              )
      )
    )
  )
)

# 3. Servidor (Lógica)
server <- function(input, output) {
  
  # Filtro Reactivo: Se actualiza cuando mueves los controles
  data_filtrada <- reactive({
    d <- data
    
    if (input$filtro_servicio != "Todos") {
      d <- d %>% filter(tipo_servicio == input$filtro_servicio)
    }
    
    if (input$filtro_dia_semana != "Todos") {
      d <- d %>% filter(as.character(dia_semana) == input$filtro_dia_semana)
    }
    d
  })
  
  # --- KPIS ---
  output$kpi_total <- renderValueBox({
    valueBox(
      nrow(data_filtrada()), 
      "Total Incidentes", 
      icon = icon("list"), color = "red"
    )
  })
  
  output$kpi_canton <- renderValueBox({
    top_canton <- data_filtrada() %>% count(canton, sort = TRUE) %>% slice(1) %>% pull(canton)
    if(length(top_canton) == 0) top_canton <- "N/A"
    
    valueBox(
      top_canton, 
      "Cantón + Conflictivo", 
      icon = icon("map-marker"), color = "yellow"
    )
  })
  
  output$kpi_dia_pico <- renderValueBox({
    top_dia <- data_filtrada() %>% count(dia_semana, sort = TRUE) %>% slice(1) %>% pull(dia_semana)
    if(length(top_dia) == 0) top_dia <- "N/A"
    
    valueBox(
      as.character(top_dia), 
      "Día Pico", 
      icon = icon("calendar"), color = "blue"
    )
  })
  
  # --- GRÁFICOS ---
  output$plot_barras <- renderPlot({
    data_filtrada() %>%
      count(subtipo) %>%
      top_n(8, n) %>%
      ggplot(aes(x = reorder(subtipo, n), y = n)) +
      geom_col(fill = "steelblue") +
      coord_flip() +
      labs(x = "", y = "Eventos") +
      theme_minimal()
  })
  
  output$plot_dias <- renderPlot({
    data_filtrada() %>%
      count(dia_semana) %>%
      ggplot(aes(x = dia_semana, y = n)) +
      geom_col(fill = "darkred") +
      labs(x = "Día de la Semana", y = "Cantidad de Incidentes") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  output$plot_servicio <- renderPlot({
    data_filtrada() %>%
      count(tipo_servicio) %>%
      ggplot(aes(x = reorder(tipo_servicio, n), y = n, fill = tipo_servicio)) +
      geom_col(show.legend = FALSE) +
      coord_flip() +
      labs(x = "", y = "Cantidad") +
      theme_minimal()
  })
  
  output$plot_tendencia <- renderPlot({
    data_filtrada() %>%
      mutate(semana = lubridate::week(fecha)) %>%
      count(semana) %>%
      ggplot(aes(x = semana, y = n)) +
      geom_line(color = "darkgreen", size = 1) +
      geom_point() +
      labs(x = "Semana", y = "Cantidad de Incidentes") +
      theme_minimal()
  })
}

# 4. Ejecutar App
shinyApp(ui, server)
