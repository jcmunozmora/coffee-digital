# Load required libraries using pacman
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(ggplot2, ggmap, sf, leaflet, htmlwidgets)

sample <- readRDS("data/derived/coffee_sample_final_20250709.rds")

# Create an interactive Leaflet map
# Define colors for each community
unique_communities_list <- unique(sample$community)
community_colors <- rainbow(length(unique_communities_list))
names(community_colors) <- unique_communities_list

# Define symbols for each category (using reliable icons)
category_symbols <- c("Demostrativa" = "star",
                     "Al Invest" = "play", 
                     "Pioneros" = "stop", 
                     "Croppie" = "home",
                     "Only Plataform" = "cog",
                     "Control" = "flag",
                     "Reemplazo" = "circle", 
                     "Sin Asignar" = "question")

# Create mapping functions for icons
get_icon <- function(category) {
  return(category_symbols[category])
}

# Create color mapping for communities (simpler approach)
get_marker_color <- function(community) {
  colors <- c("red", "blue", "green", "orange", "purple", "darkred", "lightred", "beige")
  idx <- match(community, unique_communities_list)
  if(is.na(idx) || idx > length(colors)) return("gray")
  return(colors[idx])
}

# Create color palette functions
community_pal <- colorFactor(palette = community_colors, domain = sample$community)

# Add category and community columns for easier filtering
sample$category_clean <- sample$category
sample$community_clean <- sample$community

# Create the interactive map with a simpler, more reliable approach
interactive_map <- leaflet(sample) %>%
  addTiles() %>%  # Add default OpenStreetMap tiles
  addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") %>%
  addProviderTiles(providers$OpenStreetMap, group = "Street Map") %>%
  
  # Use simple circle markers (more reliable than awesome markers)
  addCircleMarkers(
    lng = ~longitude,
    lat = ~latitude,
    color = ~community_pal(community),
    fillColor = ~community_pal(community),
    fillOpacity = 0.7,
    radius = 8,
    stroke = TRUE,
    weight = 2,
    popup = ~paste("<strong>Community:</strong>", community, "<br>",
                  "<strong>Category:</strong>", category, "<br>",
                  "<strong>Coordinates:</strong>", round(latitude, 4), ",", round(longitude, 4))
  ) %>%
  
  # Add layer control only for base maps
  addLayersControl(
    baseGroups = c("Street Map", "Satellite"),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  
  # Add legend for communities
  addLegend(
    position = "bottomright",
    pal = community_pal,
    values = ~community,
    title = "Communities",
    opacity = 0.7
  )

# Save the interactive map as HTML
saveWidget(interactive_map, file = "out/interactive_map.html", selfcontained = FALSE)

# Print the map (will display in RStudio Viewer)
interactive_map