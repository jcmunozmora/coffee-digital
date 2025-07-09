# 2. Función para encontrar las 550 fincas más cercanas
get_nearest <- function(demo_row, all_fincas, n = 550) {
  demo_coords <- c(demo_row$longitude, demo_row$latitude)
  
  candidatos <- all_fincas %>% filter(dummy_demo != 1)
  
  distancias <- distHaversine(
    matrix(candidatos[, c("longitude", "latitude")], ncol = 2),
    demo_coords
  )
  
  candidatos$distancia_m <- distancias
  
  top_550 <- candidatos %>%
    arrange(distancia_m) %>%
    slice_head(n = n) %>%
    mutate(id_demo_origen = paste0("demo_", demo_row$latitude, "_", demo_row$longitude))
  
  return(top_550)
}

# Aplicar la función a cada finca demostrativa 

get_nearest <- function(demo_row, all_fincas, n = 550) {
  
  
  # Convertir demo coords a numeric explícitamente
  demo_coords <- c(as.numeric(demo_row$longitude), as.numeric(demo_row$latitude))
  
  # Filtrar candidatos (no demostrativas)
  candidatos <- all_fincas %>% filter(dummy_demo != 1)
  
  # Asegurar que lat/lon estén como numeric
  candidatos <- candidatos %>%
    mutate(
      latitude = as.numeric(latitude),
      longitude = as.numeric(longitude)
    ) %>%
    filter(!is.na(latitude) & !is.na(longitude))  # eliminar filas sin coordenadas
  
  # Crear matriz de coordenadas
  coords_candidatos <- as.matrix(candidatos[, c("longitude", "latitude")])
  
  # Calcular distancia
  distancias <- distHaversine(coords_candidatos, demo_coords) / 1000  # Convert to kilometers
  
  candidatos$distancia_m <- distancias
  
  # Seleccionar las 550 más cercanas
  top_550 <- candidatos %>%
    arrange(distancia_m) %>%
    slice_head(n = n) %>%
    mutate(id_demo_origen = paste0("demo_", demo_row$latitude, "_", demo_row$longitude))
  
  return(top_550)
}

# Aplicar la función a cada finca demostrativa 

get_nearest_new <- function(demo_row, all_fincas, n = 550,name) {
  
  
  # Convertir demo coords a numeric explícitamente
  demo_coords <- c(as.numeric(demo_row$longitude), as.numeric(demo_row$latitude))
  
  # Filtrar candidatos (no demostrativas)
  candidatos <- all_fincas %>% filter(dummy_demo != 1)
  
  # Asegurar que lat/lon estén como numeric
  candidatos <- candidatos %>%
    mutate(
      latitude = as.numeric(latitude),
      longitude = as.numeric(longitude)
    ) %>%
    filter(!is.na(latitude) & !is.na(longitude))  # eliminar filas sin coordenadas
  
  # Crear matriz de coordenadas
  coords_candidatos <- as.matrix(candidatos[, c("longitude", "latitude")])
  
  # Calcular distancia
  distancias <- distHaversine(coords_candidatos, demo_coords) / 1000  # Convert to kilometers
  
  candidatos$distancia_m <- distancias
  
  # Seleccionar las 550 más cercanas
  top_550 <- candidatos %>%
    arrange(distancia_m) %>%
    slice_head(n = n) %>%
    mutate(id_demo_origen = paste0("demo_", demo_row$latitude, "_", demo_row$longitude))

 # Extract only main data
 top_550 <- top_550 %>% 
    select(
      nombre_finca, cedula, longitude, latitude, distancia_m, id_demo_origen,
      dummy_AI, dummy_pioner,distancia_m
    )  %>% mutate(comm=name)
  
  return(top_550)
}

