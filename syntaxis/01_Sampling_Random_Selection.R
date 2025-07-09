#########################################################################################
# Created :  22/04/2025
# Last mod: 09/07/2025
# Created by Juan Carlos Muñoz
#
# Description:
# This script processes farm data to create a final sample for analysis. It includes steps to:
# - Load and clean data
# - Create dummy variables for specific categories
# - Calculate distances to demonstration farms
# - Randomly assign farms to treatment groups
# - Save the final sample in RDS and XLSX formats
#
# Inputs:
# - Fincas_actualizado_final2.xlsx: Updated farm data
# - 3.Fincas_Seleccionadas.xlsx: Selected farms for analysis
# - Pioners.xlsx: Pioneer farms data
#
# Outputs:
# - sample_final.rds: Final sample in RDS format
# - sample_final.xlsx: Final sample in XLSX format
#
# Notes:
# - Ensure all input files are in the correct directory before running the script.
# - Set the random seed for reproducibility.
#
#########################################################################################

# Clear the environment
rm(list = ls())

# Load required packages using pacman
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(
  ggplot2, sf, dplyr, RColorBrewer, ggthemes, readxl, tidyr, gender, devtools, 
  httr, stringr, writexl, openxlsx, geodist, geosphere
)

# Load and clean data
# Input: Updated farm data
fincas <- read_excel("data/org/Fincas_actualizado_final2.xlsx") %>% janitor::clean_names()
select_farms <- read_excel("data/org/3.Fincas_Seleccionadas.xlsx") %>% janitor::clean_names()
pioners <- read_excel("data/org/Pioners.xlsx") %>% janitor::clean_names()

# Create dummy variables and clean columns
fincas <- fincas %>%
    select(nombre_finca, cedula, latitude, longitude, municipio_vereda, dummy_demo) %>%
  mutate(
    al_invest = as.integer(paste0(cedula, "_", nombre_finca) %in% 
                              paste0(select_farms$cedula, "_", select_farms$nombre_finca)),
    pioneros = as.integer(paste0(cedula, "_", nombre_finca) %in% 
                                  paste0(pioners$cedula, "_", pioners$nombre_finca)),
    latitude = as.numeric(latitude),
    longitude = as.numeric(longitude),
    id_finca = paste0(cedula, "_", nombre_finca)
  )

# Remove duplicate farms based on id_finca
fincas <- fincas %>% distinct(id_finca, .keep_all = TRUE)

# Calculate distances to demonstration farms
fincas_loc <- as.matrix(fincas[, c("longitude", "latitude")])
demos <- fincas %>% filter(dummy_demo == 1) %>% 
  mutate(id_com = row_number()) %>% 
  transmute(id_com, nombre_finca, cedula, latitude, longitude, municipio_vereda)

# Calculate distances in kilometers
distanc_1 <- distHaversine(fincas_loc, demos[demos$id_com==1, c("longitude", "latitude")]) / 1000
distanc_2 <- distHaversine(fincas_loc, demos[demos$id_com==2, c("longitude", "latitude")]) / 1000
distanc_3 <- distHaversine(fincas_loc, demos[demos$id_com==3, c("longitude", "latitude")]) / 1000

# Add distance columns to fincas
fincas <- fincas %>% 
  mutate(
    dist_1 = distanc_1,
    dist_2 = distanc_2,
    dist_3 = distanc_3,
    min_dist = pmin(dist_1, dist_2, dist_3, na.rm = TRUE),
    community = case_when(
      min_dist == dist_1 ~ "com1",
      min_dist == dist_2 ~ "com2",
      min_dist == dist_3 ~ "com3",
      TRUE ~ NA_character_
    )
  )

# Assign categories to farms
fincas <- fincas %>% 
  mutate(category = dummy_demo,
         category = ifelse(category == 0 & pioneros == 1, 2, category),
         category = ifelse(category == 0 & al_invest == 1, 3, category))

# Randomly assign remaining farms to treatment groups
set.seed(123)  # Ensure reproducibility
comm1_s <- fincas %>% filter(community == "com1" & category == 0) %>% 
        arrange(dist_1) %>%
        slice_head(n = 450) %>% 
        mutate(category = sample(rep(4:7, times = c(100, 150, 150, 50))))

comm2_s <- fincas %>% filter(community == "com2" & category == 0) %>% 
        arrange(dist_2) %>%
        slice_head(n = 450) %>% 
        mutate(category = sample(rep(4:7, times = c(100, 150, 150, 50))))

comm3_s <- fincas %>% filter(community == "com3" & category == 0) %>% 
        arrange(dist_3) %>%
        slice_head(n = 450) %>% 
        mutate(category = sample(rep(4:7, times = c(100, 150, 150, 50))))

# Combine all samples
sample <- fincas %>% filter(category %in% c(1, 2, 3))
sample <- rbind(sample, comm1_s, comm2_s, comm3_s)
sample <- rbind(sample, fincas %>% filter(!(id_finca %in% sample$id_finca)))

# Finalize sample and save
sample$category <- factor(sample$category, 
                            levels = c(0, 1, 2, 3, 4, 5, 6, 7), 
                            labels = c("Sin Asignar", "Demostrativa", "Pioneros", "Al Invest", "Croppie", "Only Plataform", "Control", "Reemplazo"))
sample <- sample %>% 
  select(id_finca, nombre_finca, cedula, latitude, longitude, municipio_vereda, community, category, dist_1, dist_2, dist_3)

# Save the sample dataset in RDS format for further analysis
saveRDS(sample, file = "data/derived/coffee_sample_final_20250709.rds")

# Save the sample dataset in XLSX format for sharing or reporting
writexl::write_xlsx(sample, path = "data/derived/coffee_sample_final_20250709.xlsx")




