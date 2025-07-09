# Load the sample dataset
sample <- readRDS("data/derived/coffee_sample_final_20250709.rds")

# Load required libraries using pacman
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(ggplot2, ggmap, sf, leaflet, htmlwidgets)

# Register Google Maps API key - SECURE METHOD
# Option 1: Read from environment variable (RECOMMENDED)
api_key <- Sys.getenv("GOOGLE_MAPS_API_KEY")

# Option 2: Read from a private file (if environment variable not set)
if (api_key == "" || is.na(api_key)) {
  # Create a file called "config.R" in your project root with: 
  # google_maps_api_key <- "YOUR_ACTUAL_API_KEY_HERE"
  if (file.exists("config.R")) {
    source("config.R")
    api_key <- google_maps_api_key
  } else {
    stop("Google Maps API key not found. Please set GOOGLE_MAPS_API_KEY environment variable or create config.R file.")
  }
}

# Register the API key
register_google(key = api_key, write = TRUE)

# Get the satellite map for the region
satellite_map <- get_map(location = c(lon = mean(sample$longitude, na.rm = TRUE), 
                                      lat = mean(sample$latitude, na.rm = TRUE)), 
                         zoom = 10, maptype = "satellite")

# Load the shapefile
district_shapes <- st_read("data/Shapes/shapes.shp")

# Transform shapefile to match the coordinate reference system of ggmap
district_shapes <- st_transform(district_shapes, crs = st_crs(4326))

# Create a map with satellite background and shapefile overlay
all <- ggmap(satellite_map) +
  geom_sf(data = district_shapes, inherit.aes = FALSE, fill = NA, color = "blue", size = 0.5) +
  geom_point(data = sample, aes(x = longitude, y = latitude, color = community, shape = category), size = 2, alpha = 0.7) +
  scale_shape_manual(values = c("Demostrativa"=8,
        "Al Invest" = 17, "Pioneros" = 9, "Croppie"=11,
        "Only Plataform"=13,"Control"=10,"Reemplazo"=20, 
        "Sin Asignar" = 20), 
                     breaks = c("Demostrativa","Pioneros",
                     "Al Invest", "Croppie","Only Plataform","Control","Reemplazo",
                      "Sin Asignar")) +
  labs(
    title = "Map of Coffee Farms with Shapefile Overlay",
    x = "Longitude",
    y = "Latitude",
    color = "Community",
    shape = "Category"
  )

ggsave(filename = "out/map_all.png" , plot = all, width = 10, height = 8)

# Create and save a map for each community, coloring points by the 'category' field
unique_communities <- unique(sample$community)

for (community in unique_communities) {
  community_data <- sample[sample$community == community, ]

  # Calculate the center of the community for a closer zoom
  community_center <- c(
    lon = mean(community_data$longitude, na.rm = TRUE),
    lat = mean(community_data$latitude, na.rm = TRUE)
  )

  # Get a satellite map with a closer zoom for the community
  community_map_background <- get_map(location = community_center, zoom = 12, maptype = "satellite")

  community_map <- ggmap(community_map_background) +
    geom_sf(data = district_shapes, inherit.aes = FALSE, fill = NA, color = "blue", size = 0.5) +
    geom_point(data = community_data, aes(x = longitude, y = latitude, color = category, shape = category), size = 3, alpha = 0.8) +
  scale_shape_manual(values = c("Demostrativa"=8,
        "Al Invest" = 17, "Pioneros" = 9, "Croppie"=11,
        "Only Plataform"=13,"Control"=10,"Reemplazo"=20, 
        "Sin Asignar" = 20), 
                     breaks = c("Demostrativa","Pioneros",
                     "Al Invest", "Croppie","Only Plataform","Control","Reemplazo",
                      "Sin Asignar")) +
  scale_color_manual(values = c("Demostrativa"="purple",
        "Al Invest" = "red", "Pioneros" = "orange", "Croppie"="green",
        "Only Plataform"="cyan","Control"="blue","Reemplazo"="brown", 
        "Sin Asignar" = "black"), 
                     breaks = c("Demostrativa","Pioneros",
                     "Al Invest", "Croppie","Only Plataform","Control","Reemplazo",
                      "Sin Asignar")) +
  labs(
    title = paste("Community Map:", community),
    x = "Longitude",
    y = "Latitude",
    color = "Category",
    shape = "Category"
  )


  # Save the map as a PNG file
  ggsave(filename = paste0("out/map_", community, ".png"), plot = community_map, width = 10, height = 8)
}

