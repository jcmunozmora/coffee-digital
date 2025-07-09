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

# Create the interactive map - fallback to basic markers if icons fail
interactive_map <- leaflet(sample) %>%
  addTiles() %>%  # Add default OpenStreetMap tiles
  addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") %>%
  addProviderTiles(providers$OpenStreetMap, group = "Street Map")

# Create the interactive map with a more direct approach
interactive_map <- leaflet(sample) %>%
  addTiles() %>%  # Add default OpenStreetMap tiles
  addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") %>%
  addProviderTiles(providers$OpenStreetMap, group = "Street Map")

# Add markers using a simple loop approach for better control
for(i in 1:nrow(sample)) {
  icon_name <- category_symbols[sample$category[i]]
  if(is.na(icon_name)) icon_name <- "circle"
  
  marker_color <- get_marker_color(sample$community[i])
  
  interactive_map <- interactive_map %>%
    addAwesomeMarkers(
      lng = sample$longitude[i],
      lat = sample$latitude[i],
      icon = awesomeIcons(
        icon = icon_name,
        iconColor = 'white',
        markerColor = marker_color,
        library = 'fa'
      ),
      popup = paste("<strong>Community:</strong>", sample$community[i], "<br>",
                   "<strong>Category:</strong>", sample$category[i], "<br>",
                   "<strong>Coordinates:</strong>", round(sample$latitude[i], 4), ",", round(sample$longitude[i], 4))
    )
}

interactive_map <- interactive_map %>%
  # Add layer control only for base maps
  addLayersControl(
    baseGroups = c("Street Map", "Satellite"),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  
  # Add legend for communities
  addLegend(
    position = "bottomright",
    colors = c("red", "blue", "green", "orange", "purple", "darkred", "lightred", "beige")[seq_along(unique_communities_list)],
    labels = unique_communities_list,
    title = "Communities",
    opacity = 0.7
  ) %>%
  
  # Add legend for categories  
  addLegend(
    position = "bottomleft",
    colors = rep("gray", length(category_symbols)),
    labels = paste(names(category_symbols), "(", category_symbols, ")"),
    title = "Category Symbols",
    opacity = 0.7
  )

# Save the interactive map as HTML
saveWidget(interactive_map, file = "out/interactive_map.html", selfcontained = FALSE)

# Print the map (will display in RStudio Viewer)
interactive_map