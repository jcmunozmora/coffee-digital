
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

_