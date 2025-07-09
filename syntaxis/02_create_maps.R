# Load the sample dataset
sample <- readRDS("data/derived/coffee_sample_final_20250709.rds")

# Load required libraries using pacman
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(ggplot2, ggmap, sf)

# Register Google Maps API key (replace 'your_api_key' with your actual key)
register_google(key = "AIzaSyCzm3YZiS0L6634vwdDl9iiepvBaZnbDc4", write = TRUE)  # Reemplaza con tu API key

# Get the satellite map for the region
satellite_map <- get_map(location = c(lon = mean(sample$longitude, na.rm = TRUE), 
                                      lat = mean(sample$latitude, na.rm = TRUE)), 
                         zoom = 10, maptype = "satellite")

# Load the shapefile
district_shapes <- st_read("data/Shapes/shapes.shp")

# Transform shapefile to match the coordinate reference system of ggmap
district_shapes <- st_transform(district_shapes, crs = st_crs(4326))

# Create a map with satellite background and shapefile overlay
ggmap(satellite_map) +
  geom_sf(data = district_shapes, inherit.aes = FALSE, fill = NA, color = "blue", size = 0.5) +
  geom_point(data = sample, aes(x = longitude, y = latitude, color = community), size = 2, alpha = 0.7) +
  labs(
    title = "Map of Coffee Farms with Shapefile Overlay",
    x = "Longitude",
    y = "Latitude",
    color = "Community"
  )

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
    scale_shape_manual(values = c("finca demostrativa" = 17, "reemplazo" = 4, "other" = 16)) +
    scale_color_manual(values = c("finca demostrativa" = "red", "reemplazo" = "black", "other" = "blue")) +
    labs(
      title = paste("Map of", community, "Community"),
      x = "Longitude",
      y = "Latitude",
      color = "Category",
      shape = "Category"
    )

  # Save the map as a PNG file
  ggsave(filename = paste0("out/map_", community, ".png"), plot = community_map, width = 10, height = 8)
}