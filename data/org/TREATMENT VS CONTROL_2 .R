#########################################################################################
############################# IDB DIGITAL FINANCE           #############################
############################# Created:  22/04/2025          #############################
############################# Last mod: 06/05/2025          #############################
############################# TREATMENT VS CONTROL_2        #############################
#########################################################################################


rm(list = ls())

#packages
library(ggplot2)
library(sf)
library(dplyr)
library(RColorBrewer)
library(ggthemes)
library(readxl)
library(sf)
library(ggplot2)
library(dplyr)
library(tidyr)
library(gender)
library(devtools)
library(httr)
library(gender)
library(dplyr)
library(stringr)
library(writexl)
library(openxlsx)
library(geodist)
library(readxl) 

#install.packages("geosphere")  # para distancias geográficas
#install.packages("dplyr")

library(geosphere)
library(dplyr)

# New Data
#fincas <- read_excel("Fincas_actualizado_final2.xlsx")
#saveRDS(fincas, file = "Fincas_actualizado_final2.rds")
#fincas <- readRDS("Fincas_actualizado_final2.rds")

#dummy 300 AI 
fincas <- read_excel("/Users/mariaantoniasuarez/Desktop/Research Assistant/EAFIT /DATA/Fincas_actualizado_final2.xlsx")
select_farms <- read_excel("/Users/mariaantoniasuarez/Desktop/Research Assistant/EAFIT /DATA/3.Fincas_Seleccionadas.xlsx")

#Crear la dummy
fincas <- fincas %>%
  mutate(dummy_AI = if_else(paste0(Cedula, "_", `Nombre finca`) %in% 
                              paste0(select_farms$Cedula, "_", select_farms$`Nombre finca`), 1, 0))


#write_xlsx(fincas, "/Users/mariaantoniasuarez/Desktop/Fincas_final_1.xlsx")


# 2. Extraer las fincas demostrativas
demos <- fincas %>% filter(dummy_demo == 1)

# Verifica que haya 3
stopifnot(nrow(demos) == 3)

# Asegurar de que sean numéricos
fincas <- fincas %>%
  mutate(
    Latitude = as.numeric(Latitude),
    Longitude = as.numeric(Longitude)
  )

demos <- demos %>%
  mutate(
    Latitude = as.numeric(Latitude),
    Longitude = as.numeric(Longitude)
  )


fincas %>% filter(is.na(as.numeric(Latitude)) | is.na(as.numeric(Longitude))) %>% select(Latitude, Longitude)

# 2. Función para encontrar las 550 fincas más cercanas
get_nearest <- function(demo_row, all_fincas, n = 550) {
  demo_coords <- c(demo_row$Longitude, demo_row$Latitude)
  
  candidatos <- all_fincas %>% filter(dummy_demo != 1)
  
  distancias <- distHaversine(
    matrix(candidatos[, c("Longitude", "Latitude")], ncol = 2),
    demo_coords
  )
  
  candidatos$distancia_m <- distancias
  
  top_550 <- candidatos %>%
    arrange(distancia_m) %>%
    slice_head(n = n) %>%
    mutate(id_demo_origen = paste0("demo_", demo_row$Latitude, "_", demo_row$Longitude))
  
  return(top_550)
}

# Aplicar la función a cada finca demostrativa 

get_nearest <- function(demo_row, all_fincas, n = 550) {
  # Convertir demo coords a numeric explícitamente
  demo_coords <- c(as.numeric(demo_row$Longitude), as.numeric(demo_row$Latitude))
  
  # Filtrar candidatos (no demostrativas)
  candidatos <- all_fincas %>% filter(dummy_demo != 1)
  
  # Asegurar que lat/lon estén como numeric
  candidatos <- candidatos %>%
    mutate(
      Latitude = as.numeric(Latitude),
      Longitude = as.numeric(Longitude)
    ) %>%
    filter(!is.na(Latitude) & !is.na(Longitude))  # eliminar filas sin coordenadas
  
  # Crear matriz de coordenadas
  coords_candidatos <- as.matrix(candidatos[, c("Longitude", "Latitude")])
  
  # Calcular distancia
  distancias <- distHaversine(coords_candidatos, demo_coords)
  
  candidatos$distancia_m <- distancias
  
  # Seleccionar las 550 más cercanas
  top_550 <- candidatos %>%
    arrange(distancia_m) %>%
    slice_head(n = n) %>%
    mutate(id_demo_origen = paste0("demo_", demo_row$Latitude, "_", demo_row$Longitude))
  
  return(top_550)
}


vecinos_list <- lapply(1:nrow(demos), function(i) {
  get_nearest(demos[i, ], fincas, n = 550)
})

muestra_final <- bind_rows(vecinos_list)

#Unir variable dummy_AI

muestra_final <- muestra_final %>%
  left_join(fincas %>% select(`Nombre finca`, Cedula, dummy_AI),
            by = c("Nombre finca", "Cedula"))

sum(muestra_final$dummy_AI == 1, na.rm = TRUE)

# Comparar si select_farms está en muestra_final

select_farms_encontradas <- inner_join(select_farms, muestra_final, by = c("Cedula", "Nombre finca"))
select_farms_no_encontradas <- anti_join(select_farms, muestra_final, by = c("Cedula", "Nombre finca"))

# Resultados
cat("✅ Fincas tratadas que están en seleccionadas:", nrow(select_farms_encontradas), "\n")
cat("⚠️ Fincas tratadas que NO están en seleccionadas:", nrow(select_farms_no_encontradas), "\n")

# (Opcional) mostrar las no encontradas
print(select_farms_no_encontradas)

##################################Revisar 82 fincas que faltan######################################################################################################################################################################################################################################################################################################################################################################################################################################################################


# Asegurar de que estas son las 307 fincas con dummy_AI == 1
fincas_AI <- fincas %>% filter(dummy_AI == 1)

# Asegurar de que ambas bases tienen la misma columna de ID, por ejemplo "farm_id"
AI_no_en_muestra <- fincas %>%
  anti_join(muestra_final, by = c("Nombre finca", "Cedula"))

nrow(AI_no_en_muestra)
# Esto debería dar 82 y da 84



# Para cada finca con dummy_demo == 1, calcular distancia a todas las demás
# Esto da una matriz de distancias
distancias <- distm(fincas[, c("Longitude", "Latitude")],
                   demos[, c("Longitude", "Latitude")], 
                    fun = distHaversine)

# Luego seleccionaste las N más cercanas a cada una


# Extrae las fincas de interés
fincas_AI <- fincas %>% filter(dummy_AI == 1)
demos <- fincas %>% filter(dummy_demo == 1)

# Calcula la distancia mínima de cada finca_AI a las fincas_demo
fincas_AI <- fincas_AI %>%
  rowwise() %>%
  mutate(min_dist_m = min(distHaversine(c(Longitude, Latitude), demos[, c("Longitude", "Latitude")]))) %>%
  ungroup()

#Cargar base vieja y comparar coordenadas con la base nueva
Base_vieja <- read_excel("/Users/mariaantoniasuarez/Desktop/Research Assistant/EAFIT /DATA/Base_vieja.xlsx")

base_vieja_AI <- Base_vieja %>%
  select(`Nombre finca`, Cedula, Latitude, Longitude)

comparacion_coords <- fincas_AI %>%
  inner_join(base_vieja_AI, by = c("Nombre finca", "Cedula"), suffix = c("_nueva", "_vieja"))

comparacion_coords <- comparacion_coords %>%
  mutate(cambio_lat = Latitude_nueva != Latitude_vieja,
         cambio_lon = Longitude_nueva != Longitude_vieja,
         cambio_coord = cambio_lat | cambio_lon)
###############comparación 

# Seleccionar columnas relevantes
base_vieja_AI <- Base_vieja %>%
  select(`Nombre finca`, Cedula, Latitude_vieja = Latitude, Longitude_vieja = Longitude)

# Seleccionar también las columnas actuales (nuevas)
fincas <- fincas %>%
  filter(dummy_AI == 1) %>%
  select(`Nombre finca`, Cedula, Latitude_nueva = Latitude, Longitude_nueva = Longitude)

# Unir ambas bases por nombre y cédula
comparacion_coords <- fincas %>%
  inner_join(base_vieja_AI, by = c("Nombre finca", "Cedula"))

# Agregar columna de comparación
comparacion_coords <- comparacion_coords %>%
  mutate(
    cambio_lat = Latitude_nueva != Latitude_vieja,
    cambio_lon = Longitude_nueva != Longitude_vieja,
    cambio_coord = cambio_lat | cambio_lon
  )

# Ver los cambios
View(comparacion_coords)

#Hacer el left_join

select_farms_no_encontradas <- select_farms_no_encontradas %>%
  left_join(comparacion_coords %>% 
              select(`Nombre finca`, Cedula, Latitude_nueva, Longitude_vieja),
            by = c("Nombre finca", "Cedula"))









# ¿Cuántas fincas tienen coordenadas distintas?
sum(comparacion_coords$cambio_coord)

# Ver cuáles son
fincas_cambiadas <- comparacion_coords %>%
  filter(cambio_coord)

# O visualízalas
View(fincas_cambiadas)

#####################################################################################################################################

#Mirar cuales estan en la muestra final 
fincas_AI <- fincas_AI %>%
  mutate(clave = paste(`Nombre finca`, Cedula, sep = "_"),
         en_muestra = clave %in% (muestra_final %>% mutate(clave = paste(`Nombre finca`, Cedula, sep = "_")) %>% pull(clave)))

#Separar las que no estan 
AI_no_en_muestra <- fincas_AI %>% filter(!en_muestra)

#Summay para ver que tan lejos estan 
summary(AI_no_en_muestra$min_dist_m)

################################################################################################################################################################################################################################################################################################################################################################################################################################################################


#Cargar Pioners 
Pioners <- read_excel("/Users/mariaantoniasuarez/Desktop/Research Assistant/EAFIT /DATA/Pioners.xlsx")


#Comparar si Pioners está en muestra_final
Pioners_encontradas <- inner_join(Pioners, muestra_final, by = c("Cedula", "Nombre finca"))
Pioners_no_encontradas <- anti_join(Pioners, muestra_final, by = c("Cedula", "Nombre finca"))

# Resultados
cat("✅ Fincas tratadas que están en seleccionadas:", nrow(Pioners_encontradas), "\n")
cat("⚠️ Fincas tratadas que NO están en seleccionadas:", nrow(Pioners_no_encontradas), "\n")

# (Opcional) mostrar las no encontradas
print(Pioners_no_encontradas)

