# install.packages("leaflet")
library(leaflet)
library(raster)

m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  setView(lng=8.3093072, lat= 47.0501682,  zoom = 7)
m %>% addProviderTiles(providers$CartoDB.Positron)
m  # Print the map


raster <- raster('C:/Users/caro1/Documents/MobiGi/Rebbau_Krankheiten/niederschlag.tif')

raster <- reclassify(raster, cbind(0, NA))
pal <- colorNumeric(c("blue","red"), values(raster),
                    na.color = "transparent")
leaflet() %>% addTiles() %>%
  addRasterImage(raster, colors = pal, opacity = 1) %>%
  addLegend(pal = pal, values = values(raster),
            title = "Niederschlag in mm")

