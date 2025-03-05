# Required packages
library(terra)
library(sf)
library(dplyr)

# Set working directory to where GEE exports are saved 
setwd("/path/to/GEE_classification")

# Load GADM level 2 boundaries for a country (e.g., Ghana)
country_sf <- st_read("/path/to/gadm41_GHA_2.json") %>% st_transform(4326)

# Function to process a country's GeoTIFF and summarize by district
process_country <- function(country_name, country_sf, tiff_path) {
  # Load the GeoTIFF
  if (!file.exists(tiff_path)) return(NULL)
  
  rast_forest <- rast(tiff_path)
  rast_clipped_cover <- crop(rast_forest$treecover2000, vect(country_sf), mask = TRUE)
  rast_clipped_loss <- crop(rast_forest$lossyear, vect(country_sf), mask = TRUE)
  
  # Initialize results data frames
  deforestation_df <- data.frame()
  treecover_df <- data.frame()
  
  # Process each district
  for (i in 1:nrow(country_sf)) {
    district <- country_sf[i, ]
    district_name <- district$NAME_2
    
    # Clip to district
    district_cover <- crop(rast_clipped_cover, vect(district), mask = TRUE)
    district_loss <- crop(rast_clipped_loss, vect(district), mask = TRUE)
    
    # Calculate tree cover area (in hectares)
    if (!is.null(district_cover) && ncell(district_cover) > 0) {
      areas <- cellSize(district_cover, unit = "m")
      tree_area <- (district_cover / 100) * areas
      treecover_ha <- global(tree_area, "sum", na.rm = TRUE)[1] / 10000
    } else {
      treecover_ha <- 0
    }
    
    # Calculate deforestation area for each year (2001–2023)
    lossyear_areas <- numeric(23)
    if (!is.null(district_loss) && ncell(district_loss) > 0) {
      areas <- cellSize(district_loss, unit = "m")
      for (year in 1:23) {
        loss_i <- ifel(district_loss == year, areas, 0)
        loss_area_i <- global(loss_i, "sum", na.rm = TRUE)[1]
        lossyear_areas[year] <- loss_area_i / 10000  # Convert to hectares
      }
    }
    
    # Store results
    treecover_df <- rbind(treecover_df, data.frame(
      Country = country_name,
      District = district_name,
      TreeCover2000_ha = treecover_ha
    ))
    
    deforestation_df <- rbind(deforestation_df, data.frame(
      Country = country_name,
      District = district_name,
      Year = 2001:2023,
      Deforestation_Area_ha = lossyear_areas
    ))
  }
  
  list(deforestation = deforestation_df, treecover = treecover_df)
}

# Process each country
results <- lapply(countries, function(country_name) {
  tiff_path <- paste0("ForestCover_LossYear_", country_name, ".tif")
  process_country(country_name, country_sf[country_sf$NAME_0 == country_name, ], tiff_path)
})

# Combine results across countries
all_deforestation <- do.call(rbind, lapply(results, function(x) x$deforestation))
all_treecover <- do.call(rbind, lapply(results, function(x) x$treecover))

# Save results
saveRDS(all_deforestation, "Deforestation_by_District.rds")
saveRDS(all_treecover, "TreeCover2000_by_District.rds")
