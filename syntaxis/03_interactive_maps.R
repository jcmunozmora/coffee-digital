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

# Create the interactive map with dynamic category controls
interactive_map <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap tiles
  addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") %>%
  addProviderTiles(providers$OpenStreetMap, group = "Street Map")

# Get unique categories
unique_categories <- unique(sample$category)

# Add circle markers for each category as separate layers
for(cat in unique_categories) {
  cat_data <- sample[sample$category == cat, ]
  
  if(nrow(cat_data) > 0) {
    interactive_map <- interactive_map %>%
      addCircleMarkers(
        data = cat_data,
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
                      "<strong>Coordinates:</strong>", round(latitude, 4), ",", round(longitude, 4)),
        group = cat  # This creates the layer group for filtering
      )
  }
}

interactive_map <- interactive_map %>%
  # Add layer control with base maps and category overlays
  addLayersControl(
    baseGroups = c("Street Map", "Satellite"),
    overlayGroups = unique_categories,
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  
  # Add legend for communities
  addLegend(
    position = "bottomright",
    pal = community_pal,
    values = sample$community,
    title = "Communities",
    opacity = 0.7
  ) %>%
  
  # Add legend for categories with their symbols
  addLegend(
    position = "bottomleft",
    colors = rep("gray", length(category_symbols)),
    labels = names(category_symbols),
    title = "Categories (Toggle Above)",
    opacity = 0.7
  )

# Save the interactive map as HTML
saveWidget(interactive_map, file = "out/interactive_map.html", selfcontained = FALSE)

# Print the map (will display in RStudio Viewer)
interactive_map