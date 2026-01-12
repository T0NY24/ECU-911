# dashboard/app.R
library(shiny)
library(shinydashboard)
library(tidyverse)

# 1. Cargar datos (Busca el archivo en la carpeta data que está un nivel arriba)
# Si te da error de ruta, asegúrate de que el archivo existe en ../data/dataset_limpio.csv
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
      
      sliderInput("filtro_hora", "Rango de Horas:",
                  min = 0, max = 23, value = c(0, 23))
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
              # --- PRIMERA FILA: KPIs (Indicadores Clave) ---
              fluidRow(
                valueBoxOutput("kpi_total", width = 4),
                valueBoxOutput("kpi_canton", width = 4),
                valueBoxOutput("kpi_hora_pico", width = 4)
              ),
              
              # --- SEGUNDA FILA: GRÁFICOS ---
              fluidRow(
                box(title = "Top Subtipos de Emergencia (Filtrado)", status = "primary", solidHeader = TRUE,
                    plotOutput("plot_barras", height = 300)),
                
                box(title = "Tendencia Horaria", status = "warning", solidHeader = TRUE,
                    plotOutput("plot_linea", height = 300))
              )
      )
    )
  )
)

# 3. Servidor (Lógica)
server <- function(input, output) {
  
  # Filtro Reactivo: Se actualiza cuando mueves los controles
  data_filtrada <- reactive({
    d <- data %>%
      filter(hora >= input$filtro_hora[1] & hora <= input$filtro_hora[2])
    
    if (input$filtro_servicio != "Todos") {
      d <- d %>% filter(tipo_servicio == input$filtro_servicio)
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
  
  output$kpi_hora_pico <- renderValueBox({
    top_hora <- data_filtrada() %>% count(hora, sort = TRUE) %>% slice(1) %>% pull(hora)
    if(length(top_hora) == 0) top_hora <- 0
    
    valueBox(
      paste0(top_hora, ":00"), 
      "Hora Pico", 
      icon = icon("clock"), color = "blue"
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
  
  output$plot_linea <- renderPlot({
    data_filtrada() %>%
      count(hora) %>%
      ggplot(aes(x = hora, y = n)) +
      geom_line(color = "darkred", size = 1.2) +
      geom_point() +
      scale_x_continuous(breaks = 0:23) +
      labs(x = "Hora", y = "Cantidad") +
      theme_minimal()
  })
}

# 4. Ejecutar App
shinyApp(ui, server)